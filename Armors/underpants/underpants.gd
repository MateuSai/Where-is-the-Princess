class_name Underpants extends Armor

func _init() -> void:
	effects = [IncreasePlayerMaxSpeed.new(10)]

	initialize(0)
	#initialize(0, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_naked_icon.png") as Texture2D, 2.2)

func enable_ability_effect(player: Player) -> void:
	#return
	player._jump()

func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/no_armor.png")

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/undies.png")
