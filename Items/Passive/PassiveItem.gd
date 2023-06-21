class_name PassiveItem

var icon: Texture


@warning_ignore("shadowed_variable")
func initialize(icon: Texture) -> void:
	self.icon = icon


func equip(_player: Player) -> void:
	pass


func unequip(_player: Player) -> void:
	pass
