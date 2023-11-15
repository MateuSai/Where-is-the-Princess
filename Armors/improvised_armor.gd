extends Armor


func _init() -> void:
	initialize("IMPROVISED_ARMOR", "IMPROVISED_ARMOR_DESCRIPTION", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_08.png"), Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png"), Rect2(16, 32, 16, 16)), 2)


func equip(player: Player) -> void:
	player.weapon_degradation_reduction += 0.2


func unequip(player: Player) -> void:
	player.weapon_degradation_reduction -= 0.2
