extends FiniteStateMachine

enum {
	CHASE,
	ATTACK,
	DEAD,
}


var attack_finished: bool = false


func start() -> void:
	set_state(CHASE)

	parent.spear_picked_up.connect(func():
		attack_finished = true
	)


func _state_logic(_delta: float) -> void:
	if state == CHASE:
		parent.move_to_target()
		parent.move()
		parent.point_to_player()
		if parent.mov_direction.y >= 0 and animation_player.current_animation != "walk":
			animation_player.play("walk")
		elif parent.mov_direction.y < 0 and animation_player.current_animation != "walk_up":
			animation_player.play("walk_up")


func _get_transition() -> int:
	var dis: float = (parent.player.position - parent.global_position).length()
	match state:
		CHASE:
			if dis <= 64:
				return ATTACK
		ATTACK:
			if attack_finished:
				attack_finished = false
				return CHASE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		CHASE:
			pass
			#animation_player.play("fly")
		ATTACK:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
			parent.attack()
		DEAD:
			pass
#			if parent.spear_and_rope:
#				parent.spear_and_rope.queue_free()
			# parent.spawn_loot()
			#animation_player.play("dead")


#func _exit_state(state_exited: int) -> void:
#	match state_exited:
#		ATTACK:
#			parent.pull_back_weapon()
