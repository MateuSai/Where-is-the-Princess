extends FiniteStateMachine


func _init() -> void:
	_add_state("above")
	_add_state("below")
	_add_state("dead")


func _state_logic(_delta: float) -> void:
	if state == states.above:
		parent.chase()
		parent.move()
#		if parent.mov_direction.y >= 0 and animation_player.current_animation != "fly":
#			animation_player.play("fly")
#		elif parent.mov_direction.y < 0 and animation_player.current_animation != "fly_up":
#			animation_player.play("fly_up")


func _get_transition() -> int:
	match state:
		states.above:
			if parent.navigation_agent.is_target_reached():
				return states.below
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.above:
			parent.show()
			parent.come_out()
			#animation_player.play("fly")
		states.below:
			parent.velocity = Vector2.ZERO
			parent.mov_direction = Vector2.ZERO
			parent.hide()
			await get_tree().create_timer(randf_range(0.7, 2.4), false).timeout
			set_state(states.above)
		states.dead:
			# parent.spawn_loot()
			animation_player.play("dead")
