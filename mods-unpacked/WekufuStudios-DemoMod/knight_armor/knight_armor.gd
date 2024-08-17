class_name KnightArmor extends Armor

func _init() -> void:
	super(2)

	_setup_ability(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_naked_icon.png") as Texture2D, 0.5, 2)

func enable_ability_effect(player: Player) -> void:
	super(player)

	player.life_component.invincible = true

func disable_ability_effect(player: Player) -> void:
	super(player)

	player.life_component.invincible = false

func get_sprite_sheet() -> Texture2D:
	return load("res://Art/player/armor_01.png")

func get_icon() -> Texture2D:
	return Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png") as Texture2D, Rect2(16, 48, 16, 16))
