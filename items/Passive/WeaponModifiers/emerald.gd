class_name Emerald extends StatusWeaponModifier

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Emmerald_item.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Emmerald_UI_desc.png")

#func _init() -> void:
#	_initialize(load("res://Art/Furniture and room elements/wardrobe.png"))

## Called when we change level and we load the weapon modifiers again
#func reequip(weapon: Weapon) -> void:
#	weapon.add_status_inflicter(StatusComponent.Status.FIRE)

func equip_to_weapon(weapon: Weapon) -> void:
	_add_status_inflicter(weapon, StatusComponent.Status.ACID)
	#weapon.add_status_inflicter(StatusComponent.Status.FIRE, amount)

func unequip_from_weapon(_weapon: Weapon) -> void:
	pass
