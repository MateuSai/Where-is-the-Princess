extends FiniteStateMachine

@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"
@onready var hitbox: Hitbox = $"../Hitbox"


func _init() -> void:
	_add_state("hidden")
	_add_state("approach")
	_add_state("melee_attack")
	_add_state("flee")
	_add_state("ranged_attack")
	_add_state("dead")


func start() -> void:
	set_state(states.hidden)


func _state_logic(_delta: float) -> void:
	match state:
		states.approach, states.flee:
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "fly":
				animation_player.play("fly")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "fly_up":
				animation_player.play("fly_up")
		states.ranged_attack:
			parent.spit()


func _get_transition() -> int:
	var vector_to_target: Vector2 = parent.target.global_position - parent.global_position
	match state:
		states.hidden:
			if vector_to_target.length() < 50:
				return states.ranged_attack
		states.approach:
			if vector_to_target.length() < 10:
				return states.melee_attack
		states.melee_attack:
			if not animation_player.is_playing():
				return states.flee
		states.flee:
			if vector_to_target.length() > 50:
				return states.ranged_attack
		states.ranged_attack:
			if vector_to_target.length() < 24:
				return states.approach

	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.hidden:
			parent.modulate.a = 0.4
		states.approach:
			pathfinding_component.set_mode(PathfindingComponent.Approach.new())
		states.melee_attack:
			hitbox.rotation = (parent.target.global_position - parent.global_position).angle()
			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
			if parent.mov_direction.y >= 0:
				animation_player.play("attack")
			else:
				animation_player.play("attack_up")
		states.flee:
			pathfinding_component.set_mode(PathfindingComponent.Flee.new())


func _exit_state(state_exited: int) -> void:
	match state_exited:
		states.hidden:
			parent.modulate.a = 1.0
