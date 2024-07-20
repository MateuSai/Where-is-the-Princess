class_name HasHead extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.has_head:
		return SUCCESS
	else:
		return FAILURE
