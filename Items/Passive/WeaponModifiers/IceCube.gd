class_name IceCube extends StatusWeaponModifier


func get_icon() -> Texture:
	return load("res://Art/19+ icons/boostB.png")


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
