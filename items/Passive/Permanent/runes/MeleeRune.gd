class_name MeleeRune extends Rune


func equip(_player: Player) -> void:
	Globals.add_weapon_damage_modifier_by_type(Weapon.Type.SPEAR, 1)
	Globals.add_weapon_damage_modifier_by_type(Weapon.Type.SWORD, 1)
	Globals.add_weapon_damage_modifier_by_type(Weapon.Type.HAMMER, 1)
	Globals.add_weapon_damage_modifier_by_type(Weapon.Type.DAGGER, 1)
	Globals.add_weapon_damage_modifier_by_type(Weapon.Type.AXE, 1)


func unequip(_player: Player) -> void:
	Globals.remove_weapon_damage_modifier_by_type(Weapon.Type.SPEAR, 1)
	Globals.remove_weapon_damage_modifier_by_type(Weapon.Type.SWORD, 1)
	Globals.remove_weapon_damage_modifier_by_type(Weapon.Type.HAMMER, 1)
	Globals.remove_weapon_damage_modifier_by_type(Weapon.Type.DAGGER, 1)
	Globals.remove_weapon_damage_modifier_by_typed(Weapon.Type.AXE, 1)


func get_icon() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omeg_icon.png")


func get_symbol() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omega.png")
