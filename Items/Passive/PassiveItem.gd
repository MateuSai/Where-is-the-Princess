class_name PassiveItem extends Resource

var icon: Texture


@warning_ignore("shadowed_variable")
func _initialize(icon: Texture) -> void:
	self.icon = icon
