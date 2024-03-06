class_name StoneHeart extends PermanentPassiveItem


func equip(player: Player) -> void:
	player.ready.connect(func() -> void:
		player.life_component.hp += 2
	)


func unequip(player: Player) -> void:
	player.life_component.hp += 2


func get_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone.png")
