class_name AxeRune extends Rune


func equip(_player: Player) -> void:
	Globals.add_weapon_damage_modifier_by_type(Weapon.Type.AXE, 1)


func unequip(_player: Player) -> void:
	Globals.remove_weapon_damage_modifier_by_type(Weapon.Type.AXE, 1)


func get_icon() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_kapp.png")
