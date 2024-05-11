class_name RatFSM extends FiniteStateMachine

enum {
	WANDER,
	IDLE,
	CHASE,
	ATTACK,
	FOLLOW,
	DEAD,
}

var rat_with_smaller_index: Character

@onready var enemy: Enemy = get_parent()
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"
@onready var attack_animation_player: AnimationPlayer = $"../AttackAnimationPlayer"
@onready var idle_timer: Timer = $"../IdleTimer"
@onready var wander_timer: Timer = $"../WanderTimer"
@onready var hitbox: Hitbox = $"../Hitbox"
@onready var character_detector: CharacterDetector = $"../EnemyDetector"
@onready var flock_steering: FlockSteering = $"../FlockSteering"


func start() -> void:
	set_state(WANDER)


func _state_logic(_delta: float) -> void:
	match state:
		CHASE, WANDER:
			enemy.move_to_target()
			#parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
		FOLLOW:
			rat_with_smaller_index = flock_steering.get_character_with_smaller_index()
			if rat_with_smaller_index.state_machine.state == WANDER:
				enemy.move_to_leader(rat_with_smaller_index)
				parent.move()
				if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
					animation_player.play("move")
				elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
					animation_player.play("move_up")
			else:
				if parent.mov_direction.y >= 0:
					animation_player.play("idle")
				else:
					animation_player.play("idle_up")


func _get_transition() -> int:
	var dis: float = (enemy.target.position - parent.global_position).length()
	match state:
		WANDER:
			if character_detector.closer_enemy:
				return CHASE
			elif not flock_steering.characters_inside.is_empty() and flock_steering.get_character_with_smaller_index() != enemy:
				return FOLLOW
			elif wander_timer.is_stopped():
				return IDLE
		IDLE:
			(parent as Enemy).mov_direction = Vector2.ZERO
			if idle_timer.is_stopped():
				return WANDER
		CHASE:
			if character_detector.closer_enemy == null:
				return WANDER
			elif dis <= 10:
				return ATTACK
			elif true:
				pass
		ATTACK:
			(parent as Enemy).mov_direction = Vector2.ZERO

			if not attack_animation_player.is_playing():
				return CHASE
		FOLLOW:
			if character_detector.closer_enemy:
				return CHASE
			else:
				rat_with_smaller_index = flock_steering.get_character_with_smaller_index()
				if not is_instance_valid(rat_with_smaller_index) or flock_steering.characters_inside.is_empty() or rat_with_smaller_index == enemy:
					return IDLE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		WANDER:
			enemy.data.max_speed = 70
			pathfinding_component.set_mode(PathfindingComponent.Wander.new())
			wander_timer.start(randf_range(3.0, 6.0))
		IDLE:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
			idle_timer.start(randf_range(1.2, 2.5))
		CHASE:
			enemy.data.max_speed = 120
			pathfinding_component.set_mode(PathfindingComponent.Approach.new())
			#animation_player.play("fly")
		ATTACK:
			hitbox.rotation = (enemy.target.position - parent.global_position).angle()
			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
			attack_animation_player.play("attack")
		DEAD:
			pass
			# parent.spawn_loot()
#			animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		WANDER:
			wander_timer.stop()
		IDLE:
			idle_timer.stop()
