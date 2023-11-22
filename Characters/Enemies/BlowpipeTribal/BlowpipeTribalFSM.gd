extends FiniteStateMachine

enum {
	IDLE,
	APPROACH,
	FLEE,
	DEAD,
}

const MAX_DISTANCE_TO_PLAYER: int = 130
const MIN_DISTANCE_TO_PLAYER: int = 70

@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"


func start() -> void:
	set_state(APPROACH)


func _state_logic(_delta: float) -> void:
	match state:
		IDLE:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif dir_to_player.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")

			parent.aim_raycast.target_position = parent.target.position - parent.global_position
			if parent.can_attack and not parent.aim_raycast.is_colliding():
				parent.can_attack = false
				parent._throw_dart()
				parent.attack_timer.start()
		APPROACH, FLEE:
			parent.move_to_target()
			parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif dir_to_player.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")


func _get_transition() -> int:
	var distance_to_player: float = (parent.target.global_position - parent.global_position).length()
	match state:
		IDLE:
			if distance_to_player > MAX_DISTANCE_TO_PLAYER:
				return APPROACH
			elif distance_to_player < MIN_DISTANCE_TO_PLAYER:
				return FLEE
		APPROACH:
			if distance_to_player < MAX_DISTANCE_TO_PLAYER:
				return IDLE
		FLEE:
			if distance_to_player > MIN_DISTANCE_TO_PLAYER:
				return IDLE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		IDLE:
			pass
			#animation_player.play("idle")
		APPROACH:
			pathfinding_component.set_mode(PathfindingComponent.Approach.new())
			#animation_player.play("APPROACH")
		FLEE:
			pathfinding_component.set_mode(PathfindingComponent.Flee.new())
		DEAD:
			# parent.spawn_loot()
			pass

