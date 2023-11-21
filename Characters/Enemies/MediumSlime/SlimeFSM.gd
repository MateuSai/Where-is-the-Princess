extends FiniteStateMachine

enum {
	WANDER,
	APPROACH,
	CIRCLE_TARGET,
	DEAD,
}

@export var start_circling_at_distance: int = 16
@export var stop_circling_at_distance: int = 30

#@onready var hitbox: Hitbox = $"../Hitbox"
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"


func start() -> void:
	if parent.mode == parent.Mode.CIRCLE:
		set_state(CIRCLE_TARGET)
	else:
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
		APPROACH:
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
		CIRCLE_TARGET:
#			parent.circle_player()
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
#		states.attack:
#			hitbox.rotation = (parent.player.position - parent.global_position).angle()
#			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
#			if parent.mov_direction.y >= 0 and animation_player.current_animation != "attack":
#				animation_player.play("attack")
#			elif parent.mov_direction.y < 0 and animation_player.current_animation != "attack_up":
#				animation_player.play("attack_up")


func _get_transition() -> int:
	var dis: float = (parent.player.position - parent.global_position).length()
	match state:
		APPROACH:
			if dis < start_circling_at_distance:
				return CIRCLE_TARGET
		CIRCLE_TARGET:
			if dis > stop_circling_at_distance:
				return APPROACH
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		WANDER:
			pathfinding_component.mode = PathfindingComponent.Wander.new()
		APPROACH:
			pathfinding_component.mode = PathfindingComponent.Approach.new()
		CIRCLE_TARGET:
			pathfinding_component.mode = PathfindingComponent.Circle.new()
#		states.dead:
#			# parent.spawn_loot()
#			animation_player.play("dead")
