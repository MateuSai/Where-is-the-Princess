class_name WoodenMagicShield extends MagicShield


func _init() -> void:
	max_hp = 3
	spritesheet = load("res://Art/items/shield_rotating_player.png")

	if first_time_pickup:
		hp = 3

	super()


func get_icon() -> Texture2D:
	return load("res://Art/items/shield_icon.png")


func get_big_icon() -> Texture2D:
	return load("res://Art/items/shield_UI_desc.png")


func get_quality() -> Item.Quality:
	return Item.Quality.COMMON
