class_name GooseHasWeapon extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
    if (actor as Goose).weapon:
        return SUCCESS
    else:
        return FAILURE