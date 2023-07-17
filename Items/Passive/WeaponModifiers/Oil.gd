class_name Oil extends WeaponModifier


func _init() -> void:
	_initialize(load("res://Art/Furniture and room elements/wardrobe.png"))


## Called when we change level and we load the weapon modifiers again
func reequip(weapon: Weapon) -> void:
	weapon.add_status_inflicter(StatusComponent.Status.FIRE)


func equip(player: Player) -> void:
	player.weapons.current_weapon.add_status_inflicter(StatusComponent.Status.FIRE)


func unequip(_player: Player) -> void:
	pass
