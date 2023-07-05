class_name Mod

var resource_path: String
var enabled: bool = true

@warning_ignore("shadowed_variable")
func _init(resource_path: String) -> void:
	self.resource_path = resource_path
