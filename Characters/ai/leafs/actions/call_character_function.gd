class_name CallCharacterFunction extends ActionLeaf

@export var function_name: String = ""

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.call(function_name)

	return SUCCESS
