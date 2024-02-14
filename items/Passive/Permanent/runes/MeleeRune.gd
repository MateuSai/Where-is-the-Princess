class_name MeleeRune extends Rune


func equip(_player: Player) -> void:
	Globals.add_weapon_damage_modifier_by_type(WeaponData.Type.SPEAR, 1)
	Globals.add_weapon_damage_modifier_by_type(WeaponData.Type.SWORD, 1)
	Globals.add_weapon_damage_modifier_by_type(WeaponData.Type.HAMMER, 1)
	Globals.add_weapon_damage_modifier_by_type(WeaponData.Type.DAGGER, 1)
	Globals.add_weapon_damage_modifier_by_type(WeaponData.Type.AXE, 1)


func unequip(_player: Player) -> void:
	Globals.remove_weapon_damage_modifier_by_type(WeaponData.Type.SPEAR, 1)
	Globals.remove_weapon_damage_modifier_by_type(WeaponData.Type.SWORD, 1)
	Globals.remove_weapon_damage_modifier_by_type(WeaponData.Type.HAMMER, 1)
	Globals.remove_weapon_damage_modifier_by_type(WeaponData.Type.DAGGER, 1)
	Globals.remove_weapon_damage_modifier_by_typed(WeaponData.Type.AXE, 1)


func get_quality() -> Quality:
	return Quality.CHINGON


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omega_icon.png") as Texture2D


func get_symbol() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omega.png") as Texture2D
