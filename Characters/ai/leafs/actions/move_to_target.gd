class_name MoveToTarget extends ActionLeaf

@export var closer_than: int = 8

func tick(actor: Node, _blackboard: Blackboard) -> int:
    actor.move_to_target()
    actor.move()
    if actor.mov_direction.y >= 0 and actor.animation_player.current_animation != "move":
        actor.animation_player.play("move")
    elif actor.mov_direction.y < 0 and actor.animation_player.current_animation != "move_up":
        actor.animation_player.play("move_up")

    if ((actor as Enemy).target.global_position - (actor as Enemy).global_position).length() < closer_than:
        return SUCCESS

    return RUNNING