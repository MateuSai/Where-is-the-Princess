class_name BodenTheDruidFSM extends FiniteStateMachine

enum {
	IDLE,
	MOVE,
	TRANSFORM,
	BEAR_RUN,
	BEAR_MELEE_ATTACK,
	BEAR_THROW_ROCK,
	DEAD,
}

const MAX_DISTANCE_TO_PLAYER: int = 70
const MIN_DISTANCE_TO_PLAYER: int = 45

var rock_dir: Vector2

@onready var MAX_DISTANCE_FOR_MELEE_ATTACK: float = $"../MeleeHitbox/CollisionShape2D".shape.radius * 2
@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var rock_container: Node2D = $"../RockContainer"
@onready var rock_attack_timer: Timer = $"../RockAttackTimer"
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"


func start() -> void:
	set_state(MOVE)

	rock_attack_timer.timeout.connect(func() -> void:
		set_state(BEAR_THROW_ROCK)
	)


func _state_logic(_delta: float) -> void:
	match state:
		IDLE:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif dir_to_player.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")
			if dir_to_player.x > 0 and sprite.flip_h:
				sprite.flip_h = false
			elif dir_to_player.x < 0 and not sprite.flip_h:
				sprite.flip_h = true

			parent.move_staff()
		MOVE:
			var distance_to_player: float = (parent.target.global_position - parent.global_position).length()
			if distance_to_player > MAX_DISTANCE_TO_PLAYER and not pathfinding_component.mode is PathfindingComponent.Approach:
				pathfinding_component.set_mode(PathfindingComponent.Approach.new())
			elif distance_to_player < MIN_DISTANCE_TO_PLAYER and not pathfinding_component.mode is PathfindingComponent.Flee:
				pathfinding_component.set_mode(PathfindingComponent.Flee.new())

			parent.move_to_target()
			parent.move()
			if parent.can_move:
				var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
				if dir_to_player.y >= 0 and animation_player.current_animation != "walk":
					animation_player.play("walk")
				elif dir_to_player.y < 0 and animation_player.current_animation != "walk_up":
					animation_player.play("walk_up")
			elif not animation_player.current_animation.begins_with("idle"):
				var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
				if dir_to_player.y >= 0:
					animation_player.play("idle")
				elif dir_to_player.y < 0:
					animation_player.play("idle_up")

			parent.move_staff()

		BEAR_RUN:
			parent.move_to_target()
			parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "bear_run":
				animation_player.play("bear_run")
			elif dir_to_player.y < 0 and animation_player.current_animation != "bear_run_up":
				animation_player.play("bear_run_up")


func _get_transition() -> int:
	var distance_to_player: float = (parent.target.global_position - parent.global_position).length()
	match state:
		IDLE:
			if distance_to_player > MAX_DISTANCE_TO_PLAYER or distance_to_player < MIN_DISTANCE_TO_PLAYER:
				return MOVE
		MOVE:
			if distance_to_player < MAX_DISTANCE_TO_PLAYER and distance_to_player > MIN_DISTANCE_TO_PLAYER:
				return IDLE
		TRANSFORM:
			if not animation_player.is_playing():
				return BEAR_RUN
		BEAR_RUN:
			if distance_to_player <= MAX_DISTANCE_FOR_MELEE_ATTACK:
				return BEAR_MELEE_ATTACK
		BEAR_MELEE_ATTACK, BEAR_THROW_ROCK:
			if not animation_player.is_playing():
				if randi() % 2 == 0:
					return BEAR_THROW_ROCK
				else:
					return BEAR_RUN
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		IDLE:
			pass
			#animation_player.play("idle")
		MOVE:
			pass
			#animation_player.play("move")
		TRANSFORM:
			parent.life_component.invincible = true
			animation_player.play("transform")
			$"../BirdAttackTimer".stop()
			$"../BirdAttackTimer".queue_free()
			$"../LightningAttackTimer".stop()
			$"../LightningAttackTimer".queue_free()
			$"../StaffPivot".queue_free()
#			pathfinding_component.mode.timer.wait_time = 0.15
			parent.max_speed = 160
			parent.acceleration = 70
			parent.mass = 150
			parent.can_move = true
		BEAR_RUN:
			pathfinding_component.set_mode(PathfindingComponent.Approach.new())
			rock_attack_timer.start(randf_range(0.8, 2.0))
		BEAR_MELEE_ATTACK:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y < 0:
				animation_player.play("melee_attack_up")
			else:
				animation_player.play("melee_attack")
			$"../MeleeHitbox".rotation = dir_to_player.angle()
			$"../MeleeHitbox".knockback_direction = dir_to_player
		BEAR_THROW_ROCK:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			rock_dir = dir_to_player
			if dir_to_player.y < 0:
				parent.move_child(rock_container, 0)
				animation_player.play("throw_rock_up")
			else:
				parent.move_child(rock_container, parent.get_child_count()-1)
				animation_player.play("throw_rock")
			if dir_to_player.x > 0 and sprite.flip_h:
				sprite.flip_h = false
				rock_container.scale.x = 1
			elif dir_to_player.x < 0 and not sprite.flip_h:
				sprite.flip_h = true
				rock_container.scale.x = -1
		DEAD:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		TRANSFORM:
			parent.life_component.invincible = false
		BEAR_RUN:
			rock_attack_timer.stop()
