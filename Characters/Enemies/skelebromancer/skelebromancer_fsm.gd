class_name SkelebromancerFSM extends FiniteStateMachine

const MAX_DISTANCE_TO_PLAYER: int = 150
const MIN_DISTANCE_TO_PLAYER: int = 70

@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"


func _init() -> void:
	_add_state("idle")
	_add_state("approach")
	_add_state("flee")
	_add_state("dead")


func start() -> void:
	set_state(states.approach)


func _state_logic(_delta: float) -> void:
	match state:
		states.idle:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif dir_to_player.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")
#			parent.aim_bow()
		states.approach:
			parent.move_to_target()
			parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif dir_to_player.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
#			parent.aim_bow()
		states.flee:
			parent.move_to_target()
			parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif dir_to_player.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")


func _get_transition() -> int:
	var distance_to_player: float = (parent.player.position - parent.global_position).length()
	match state:
		states.idle:
			if distance_to_player > MAX_DISTANCE_TO_PLAYER:
				return states.approach
			elif distance_to_player < MIN_DISTANCE_TO_PLAYER:
				return states.flee
		states.approach:
			if distance_to_player < MAX_DISTANCE_TO_PLAYER:
				return states.idle
		states.flee:
			if distance_to_player > MIN_DISTANCE_TO_PLAYER:
				return states.idle
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
#		states.idle:
			#animation_player.play("idle")
		states.approach:
#			if not bow_animation_player.is_playing():
#				bow_animation_player.play("attack")
			pathfinding_component.set_mode(PathfindingComponent.Approach.new())
		states.flee:
#			bow_animation_player.play("RESET")
			pathfinding_component.set_mode(PathfindingComponent.Flee.new())
			#animation_player.play("move")
#		states.dead:
#			bow_animation_player.play("RESET")
#			# parent.spawn_loot()
#			animation_player.play("dead")

