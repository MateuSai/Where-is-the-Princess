extends Armor


func _init() -> void:
	initialize(10, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_mercenary_icon.png"), 15, 5)


func enable_ability_effect(player: Player) -> void:
	player.damage_multiplier += 1
	player.life_component.damage_taken_multiplier += 1


func disable_ability_effect(player: Player) -> void:
	player.damage_multiplier -= 1
	player.life_component.damage_taken_multiplier -= 1


func get_sprite_sheet() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_02.png")


func get_icon() -> Texture:
	return Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png"), Rect2(0, 0, 16, 16))
