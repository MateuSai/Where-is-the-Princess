class_name SwordRune extends Rune


func equip(_player: Player) -> void:
	Globals.add_weapon_damage_modifier_by_type(WeaponData.Type.SWORD, 1)


func unequip(_player: Player) -> void:
	Globals.remove_weapon_damage_modifier_by_type(WeaponData.Type.SWORD, 1)


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_alf_icon.png")


func get_symbol() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_alf.png")
