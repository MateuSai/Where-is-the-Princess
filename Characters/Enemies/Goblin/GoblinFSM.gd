extends FiniteStateMachine


enum {
	IDLE,
	MOVE,
	DEAD,
}


@onready var attack_timer: Timer = $"../AttackTimer"
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"


func start() -> void:
	set_state(IDLE)


func _state_logic(_delta: float) -> void:
	match state:
		IDLE:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif dir_to_player.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")

			parent.aim_raycast.target_position = parent.target.global_position - parent.global_position
			if parent.can_attack and not parent.aim_raycast.is_colliding():
				parent.can_attack = false
				parent._throw_knife()
				attack_timer.start()
		MOVE:
			var distance_to_player: float = (parent.target.global_position - parent.global_position).length()
			if distance_to_player > Goblin.MAX_DISTANCE_TO_PLAYER and not pathfinding_component.mode is PathfindingComponent.Approach:
				pathfinding_component.set_mode(PathfindingComponent.Approach.new())
			elif distance_to_player < Goblin.MIN_DISTANCE_TO_PLAYER and not pathfinding_component.mode is PathfindingComponent.Flee:
				pathfinding_component.set_mode(PathfindingComponent.Flee.new())

			parent.move_to_target()
			parent.move()
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
			# parent.spawn_loot()
			animation_player.play("dead")

