class_name UpdateAnimationAccordingToMovdirection extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
    if (actor as Enemy).mov_direction.length() > 0.05:
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