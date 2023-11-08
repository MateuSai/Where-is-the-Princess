extends FiniteStateMachine


func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("hurt")
	_add_state("dead")


func start() -> void:
	set_state(states.idle)


func _state_logic(_delta: float) -> void:
	match state:
		states.idle:
			parent.get_input()
			parent.move()
			#var mouse_direction: Vector2 = (parent.get_global_mouse_position() - parent.global_position).normalized()
			if parent.mouse_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
		states.move:
			parent.get_input()
			parent.move()
			#var mouse_direction: Vector2 = (parent.get_global_mouse_position() - parent.global_position).normalized()
			if parent.mouse_direction.y >= 0:
				if (parent.mouse_direction.x > 0 and parent.mov_direction.x < 0) or (parent.mouse_direction.x < 0 and parent.mov_direction.x > 0):
					animation_player.play_backwards("move")
				else:
					animation_player.play("move")
			else:
				if (parent.mouse_direction.x > 0 and parent.mov_direction.x < 0) or (parent.mouse_direction.x < 0 and parent.mov_direction.x > 0):
					animation_player.play_backwards("move_up")
				else:
					animation_player.play("move_up")
		#animation_tree.set("parameters/" + states.keys()[state] + "/blend_position", (parent.get_global_mouse_position() - parent.global_position).normalized().y)


func _get_transition() -> int:
	match state:
		states.idle:
			if parent.velocity.length() > 10:
				return states.move
		states.move:
			if parent.velocity.length() < 10:
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				return states.idle
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			pass
			#animation_player.play("idle")
			#animation_tree_state_machine.travel("idle")
		states.move:
			pass
			#animation_player.play("move")
			#animation_tree_state_machine.travel("move")
		states.hurt:
			animation_player.play("hurt")
			parent.weapons.cancel_attack()
		states.dead:
			animation_player.play("dead")
			parent.weapons.cancel_attack()
