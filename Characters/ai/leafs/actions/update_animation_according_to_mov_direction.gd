class_name UpdateAnimationAccordingToMovdirection extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if (actor as Enemy).mov_direction.length() > 0.05:
		if (actor.animation_player as AnimationPlayer).has_animation("move_left"):
			if actor.mov_direction.y >= 0 and abs(actor.mov_direction.y) > abs(actor.mov_direction.x) and actor.animation_player.current_animation != "move":
				actor.animation_player.play("move")
			elif actor.mov_direction.y < 0 and abs(actor.mov_direction.y) > abs(actor.mov_direction.x) and actor.animation_player.current_animation != "move_up":
				actor.animation_player.play("move_up")
			elif actor.mov_direction.x >= 0 and abs(actor.mov_direction.x) > abs(actor.mov_direction.y) and actor.animation_player.current_animation != "move_right":
				actor.animation_player.play("move_right")
			elif actor.mov_direction.x < 0 and abs(actor.mov_direction.x) > abs(actor.mov_direction.y) and actor.animation_player.current_animation != "move_left":
				actor.animation_player.play("move_left")
		else:
			if actor.mov_direction.y >= 0 and actor.animation_player.current_animation != "move":
				actor.animation_player.play("move")
			elif actor.mov_direction.y < 0 and actor.animation_player.current_animation != "move_up":
				actor.animation_player.play("move_up")
	else:
		if actor.mov_direction.y >= 0 and actor.animation_player.current_animation != "idle":
			actor.animation_player.play("idle")
		elif actor.mov_direction.y < 0 and actor.animation_player.current_animation != "idle_up":
			actor.animation_player.play("idle_up")

	return SUCCESS
