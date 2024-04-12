class_name StaminaMagicShield extends MagicShield

func _init() -> void:
	max_hp = 3
	spritesheet = load("res://Art/items/shield_rotating_player.png")

	if first_time_pickup:
		hp = 3

	effects = [IncreaseStaminaRegenerationPerSecond.new(3.0)]

	super()

func get_icon() -> Texture2D:
	return load("res://Art/items/shield_icon.png")

func get_quality() -> Item.Quality:
	return Item.Quality.CHINGON
