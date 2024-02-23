extends PermanentPassiveItem


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/soul_amulet.png")


func equip(_player: Player) -> void:
	Enemy.coin_multiplier += 0.5


func unequip(_player: Player) -> void:
	Enemy.coin_multiplier -= 0.5
