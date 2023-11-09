extends FiniteStateMachine

#@onready var hitbox: Hitbox = $"../Hitbox"
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"


func _init() -> void:
	_add_state("wander")
	_add_state("approach")
	_add_state("circle_player")
#	_add_state("attack")
	_add_state("dead")


func start() -> void:
	if parent.mode == parent.Mode.CIRCLE:
		set_state(states.circle_player)
	else:
		set_state(states.wander)


func _state_logic(_delta: float) -> void:
	match state:
		states.wander, states.approach, states.circle_player:
			parent.move_to_target()
			parent.move()
#			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
#				animation_player.play("move")
#			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
#				animation_player.play("move_up")
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
		states.approach:
			if dis < 16:
				return states.circle_player
		states.circle_player:
			if dis > 30:
				return states.approach
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.wander:
			animation_player.play("move")
			pathfinding_component.mode = PathfindingComponent.Wander.new()
		states.approach:
			animation_player.play("move")
			pathfinding_component.mode = PathfindingComponent.Approach.new()
		states.circle_player:
			animation_player.play("move")
			pathfinding_component.mode = PathfindingComponent.Circle.new()
#		states.dead:
#			# parent.spawn_loot()
#			animation_player.play("dead")
