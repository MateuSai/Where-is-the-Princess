class_name AdditionalHeart extends PlayerUpgrade


func equip(player: Player) -> void:
	player.life_component.max_hp += 4
	player.life_component.hp += 4


func get_icon() -> Texture2D:
	return load("res://Art/Dust.png")


func get_dark_soul_cost() -> int:
	return 5


func get_max_amount() -> int:
	return 4
