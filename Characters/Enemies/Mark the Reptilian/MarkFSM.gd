extends FiniteStateMachine


func _init() -> void:
	_add_state("chase")
	_add_state("dead")


func _ready() -> void:
	set_state(states.chase)


func _state_logic(_delta: float) -> void:
	if state == states.chase:
		parent.chase()
		parent.move()
		if parent.mov_direction.y >= 0 and animation_player.current_animation != "walk":
			animation_player.play("walk")
		elif parent.mov_direction.y < 0 and animation_player.current_animation != "walk_up":
			animation_player.play("walk_up")


func _get_transition() -> int:
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.chase:
			pass
			#animation_player.play("fly")
		states.dead:
			# parent.spawn_loot()
			animation_player.play("dead")
