class_name AdditionalHeart extends PlayerUpgrade


func pick_up(player: Player) -> void:
	player.life_component.max_hp += 4


func get_icon() -> Texture2D:
	return load("res://Art/Dust.png")
