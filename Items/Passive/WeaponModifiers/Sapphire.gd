class_name Sapphire extends StatusWeaponModifier


func get_icon() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/Items/Sapphire_item.png")


#func _init() -> void:
#	_initialize(load("res://Art/19+ icons/boostB.png"))


## Called when we change level and we load the weapon modifiers again
#func reequip(weapon: Weapon) -> void:
#	weapon.add_status_inflicter(StatusComponent.Status.FIRE)


func equip(weapon: Weapon) -> void:
	_add_status_inflicter(weapon, StatusComponent.Status.ICE)
	#weapon.add_status_inflicter(StatusComponent.Status.ICE, amount)


func unequip(_weapon: Weapon) -> void:
	pass
