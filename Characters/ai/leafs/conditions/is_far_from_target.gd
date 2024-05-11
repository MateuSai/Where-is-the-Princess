class_name IsFarFromTarget extends ConditionLeaf

@export var farther_than: int = 32

func tick(actor: Node, _blackboard: Blackboard) -> int:
    var vector: Vector2 = (actor as Enemy).target.global_position - (actor as Enemy).global_position
    
    if vector.length() > farther_than:
        return SUCCESS
    else:
        return FAILURE
