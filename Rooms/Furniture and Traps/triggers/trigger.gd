class_name Trigger extends Area2D

@export var id: int = -1

func activate() -> void:
	for child: Node in get_tree().get_nodes_in_group("enabler_" + str(id)):
		assert(child.has_node("RemoteTrap"))
		assert(child.get_node("RemoteTrap") is RemoteTrap)
		(child.get_node("RemoteTrap") as RemoteTrap).activate()