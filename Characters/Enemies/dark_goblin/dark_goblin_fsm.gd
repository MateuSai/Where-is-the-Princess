extends FiniteStateMachine

enum {
	IDLE,
	MOVE,
	DEAD,
}

const MIN_ATTACK_COOLDOWN: float = 1.5
const MAX_ATTACK_COOLDOWN: float = 2.8

const MIN_ABILTY_COOLDOWN: float = 7.0
const MAX_ABILITY_COOLDOWN: float = 13.0


@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"
@onready var swap_cooldown_timer: Timer = get_node("../SwapCooldownTimer")
@onready var attack_timer: Timer = get_node("../AttackTimer")


func start() -> void:
	swap_cooldown_timer.start(randf_range(MIN_ABILTY_COOLDOWN, MAX_ABILITY_COOLDOWN))
	attack_timer.start(randf_range(MIN_ATTACK_COOLDOWN, MAX_ATTACK_COOLDOWN))
	attack_timer.timeout.connect(func() -> void:
		if swap_cooldown_timer.is_stopped() and (parent.player.position - parent.global_position).length() < parent.MAX_DISTANCE_TO_PLAYER and (parent.player.position - parent.global_position).length() > 16:
			parent.swap_and_throw_knives()
			swap_cooldown_timer.start(randf_range(MIN_ABILTY_COOLDOWN, MAX_ABILITY_COOLDOWN))
		else:
			parent.normal_attack()
		attack_timer.start(randf_range(MIN_ATTACK_COOLDOWN, MAX_ATTACK_COOLDOWN))
	)
	set_state(MOVE)


func _state_logic(_delta: float) -> void:
	match state:
		IDLE:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif dir_to_player.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")
		MOVE:
			var distance_to_player: float = (parent.target.global_position - parent.global_position).length()
			if distance_to_player > DarkGoblin.MAX_DISTANCE_TO_PLAYER and not pathfinding_component.mode is PathfindingComponent.Approach:
				pathfinding_component.set_mode(PathfindingComponent.Approach.new())
			elif distance_to_player < DarkGoblin.MIN_DISTANCE_TO_PLAYER and not pathfinding_component.mode is PathfindingComponent.Flee:
				pathfinding_component.set_mode(PathfindingComponent.Flee.new())

			parent.move_to_target()
			#parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif dir_to_player.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")


func _get_transition() -> int:
	match state:
		IDLE:
			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
				return MOVE
		MOVE:
			if parent.distance_to_player < parent.MAX_DISTANCE_TO_PLAYER and parent.distance_to_player > parent.MIN_DISTANCE_TO_PLAYER:
				return IDLE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		IDLE:
			pass
			#animation_player.play("idle")
		MOVE:
			pass
			#animation_player.play("move")
		DEAD:
			attack_timer.stop()
			# parent.spawn_loot()
			animation_player.play("dead")
