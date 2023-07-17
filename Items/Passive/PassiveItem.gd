class_name PassiveItem extends Resource

var icon: Texture


@warning_ignore("shadowed_variable")
func _initialize(icon: Texture) -> void:
	self.icon = icon


## This function will be executed when the player picks up the passive item
func equip(_player: Player) -> void:
	pass


func unequip(_player: Player) -> void:
	pass
