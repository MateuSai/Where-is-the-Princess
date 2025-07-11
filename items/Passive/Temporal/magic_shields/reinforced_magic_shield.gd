class_name ReinforcedMagicShield extends MagicShield

func _init() -> void:
	max_hp = 8
	spritesheet = load("res://Art/items/shield_rotating_player_metal.png")

	if first_time_pickup:
		hp = 8

	super()


func get_icon() -> Texture2D:
	return load("res://Art/items/shield_icon_metal.png")


func get_big_icon() -> Texture2D:
	return load("res://Art/items/shield_metal_UI_desc.png")


func get_quality() -> Item.Quality:
	return Item.Quality.CHINGON
