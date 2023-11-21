extends FiniteStateMachine

enum {
	IDLE,
	MOVE,
	HURT,
	DEAD,
}


func start() -> void:
	set_state(IDLE)


func _state_logic(_delta: float) -> void:
	match state:
		IDLE:
			parent.get_input()
			parent.move()
			#var mouse_direction: Vector2 = (parent.get_global_mouse_position() - parent.global_position).normalized()
			if parent.mouse_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
		MOVE:
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
		IDLE:
			if parent.velocity.length() > 10:
				return MOVE
		MOVE:
			if parent.velocity.length() < 10:
				return IDLE
		HURT:
			if not animation_player.is_playing():
				return IDLE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		IDLE:
			pass
			#animation_player.play("idle")
			#animation_tree_state_machine.travel("idle")
		MOVE:
			pass
			#animation_player.play("move")
			#animation_tree_state_machine.travel("move")
		HURT:
			animation_player.play("hurt")
			parent.weapons.cancel_attack()
		DEAD:
			animation_player.play("dead")
			parent.weapons.cancel_attack()
