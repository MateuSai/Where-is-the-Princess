class_name IsCloseToTarget extends ConditionLeaf

@export var closer_than: int = 8

func tick(actor: Node, _blackboard: Blackboard) -> int:
    var vector: Vector2 = (actor as Enemy).target.global_position - (actor as Enemy).global_position
    
    if vector.length() < closer_than:
        return SUCCESS
    else:
        return FAILURE