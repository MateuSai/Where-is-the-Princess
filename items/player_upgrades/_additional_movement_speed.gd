class_name AdditionalMovementSpeed extends PlayerUpgrade


func equip(player: Player) -> void:
	player.data.max_speed += 20


func get_max_amount() -> int:
	return 2


func get_icon() -> Texture2D:
	return load("res://Art/Dust.png")


func get_dark_soul_cost() -> int:
	return 1
