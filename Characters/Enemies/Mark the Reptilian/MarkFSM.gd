extends FiniteStateMachine


func _init() -> void:
	_add_state("chase")
	_add_state("attack")
	_add_state("dead")


func _ready() -> void:
	set_state(states.chase)


func _state_logic(_delta: float) -> void:
	if state == states.chase:
		parent.chase()
		parent.move()
		parent.point_to_player()
		if parent.mov_direction.y >= 0 and animation_player.current_animation != "walk":
			animation_player.play("walk")
		elif parent.mov_direction.y < 0 and animation_player.current_animation != "walk_up":
			animation_player.play("walk_up")


func _get_transition() -> int:
	var dis: float = (parent.player.position - parent.global_position).length()
	match state:
		states.chase:
			if dis <= 64:
				return states.attack
		states.attack:
			if dis > 64:
				return states.chase
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.chase:
			pass
			#animation_player.play("fly")
		states.attack:
			animation_player.play("attack")
		states.dead:
			# parent.spawn_loot()
			animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		states.attack:
			parent.pull_back_weapon()
