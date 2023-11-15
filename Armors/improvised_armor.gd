extends Armor


func _init() -> void:
	initialize(2)


func equip(player: Player) -> void:
	player.weapon_degradation_reduction += 0.2


func unequip(player: Player) -> void:
	player.weapon_degradation_reduction -= 0.2


func get_sprite_sheet() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_08.png")


func get_icon() -> Texture:
	return Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png"), Rect2(16, 32, 16, 16))
