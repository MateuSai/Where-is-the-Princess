class_name PoopSlimeFSM extends FiniteStateMachine

enum {
	WANDER,
	DEAD,
}

#@onready var hitbox: Hitbox = $"../Hitbox"
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"


func start() -> void:
	set_state(WANDER)


func _state_logic(_delta: float) -> void:
	match state:
		WANDER:
#			if parent.navigation_agent.is_target_reached() or not parent.navigation_agent.is_target_reachable():
#				parent.target_random_near_position()
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")


func _get_transition() -> int:
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		WANDER:
			pathfinding_component.mode = PathfindingComponent.Wander.new()
