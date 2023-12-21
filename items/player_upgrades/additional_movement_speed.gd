class_name AdditionalMovementSpeed extends PlayerUpgrade


func equip(player: Player) -> void:
	player.max_speed += 10


func get_max_amount() -> int:
	return 2


func get_icon() -> Texture2D:
	return load("res://Art/Dust.png")
