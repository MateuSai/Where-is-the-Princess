class_name MoveToTarget extends ActionLeaf

@export var closer_than: int = 8

func tick(actor: Node, _blackboard: Blackboard) -> int:
    actor.move_to_target()
    actor.move()

    if ((actor as Enemy).target.global_position - (actor as Enemy).global_position).length() < closer_than:
        return SUCCESS

    return RUNNING