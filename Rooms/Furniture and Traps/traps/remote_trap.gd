class_name RemoteTrap extends Node


func activate() -> void:
	assert(get_parent().has_method("activate"))
	get_parent().activate()
