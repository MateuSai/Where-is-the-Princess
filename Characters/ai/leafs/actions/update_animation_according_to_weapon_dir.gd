class_name UpdateAnimationAccordingToWeaponDir extends ActionLeaf

@onready var weapons: EnemyWeapons = owner.get_node("EnemyWeapons")

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var dir: Vector2 = Vector2.RIGHT.rotated(weapons.current_weapon.rotation)

	if (actor as Enemy).mov_direction.length() > 0.05:
		if (actor.animation_player as AnimationPlayer).has_animation("move_left"):
			if dir.y >= 0 and abs(dir.y) > abs(dir.x) and actor.animation_player.current_animation != "move":
				actor.animation_player.play("move")
			elif dir.y < 0 and abs(dir.y) > abs(dir.x) and actor.animation_player.current_animation != "move_up":
				actor.animation_player.play("move_up")
			elif dir.x >= 0 and abs(dir.x) > abs(dir.y) and actor.animation_player.current_animation != "move_right":
				actor.animation_player.play("move_right")
			elif dir.x < 0 and abs(dir.x) > abs(dir.y) and actor.animation_player.current_animation != "move_left":
				actor.animation_player.play("move_left")
		else:
			if dir.y >= 0 and actor.animation_player.current_animation != "move":
				actor.animation_player.play("move")
			elif dir.y < 0 and actor.animation_player.current_animation != "move_up":
				actor.animation_player.play("move_up")
	else:
		if dir.y >= 0 and actor.animation_player.current_animation != "idle":
			actor.animation_player.play("idle")
		elif dir.y < 0 and actor.animation_player.current_animation != "idle_up":
			actor.animation_player.play("idle_up")

	return SUCCESS
