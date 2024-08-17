extends Armor

func _init() -> void:
	super(6)

	_setup_ability(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_mercenary_icon.png") as Texture2D, 15, 5)

func enable_ability_effect(player: Player) -> void:
	player.damage_multiplier *= 2
	player.life_component.damage_taken_multiplier *= 2

func disable_ability_effect(player: Player) -> void:
	player.damage_multiplier /= 2
	player.life_component.damage_taken_multiplier /= 2

func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_02.png")

func get_icon() -> Texture2D:
	return Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png") as Texture2D, Rect2(0, 0, 16, 16))
