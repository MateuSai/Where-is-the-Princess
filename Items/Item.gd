class_name Item extends Resource


var icon: Texture


@warning_ignore("shadowed_variable")
func _initialize(icon: Texture) -> void:
	self.icon = icon


## This function is executed when the player interacts with the item when it's on the floor
func pick_up(_player: Player) -> void:
	pass
