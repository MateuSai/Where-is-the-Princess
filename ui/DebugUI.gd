class_name DebugUI extends Control


func _ready() -> void:
	if not Globals.debug:
		queue_free()
