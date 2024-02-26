extends PermanentPassiveItem


func get_icon() -> Texture2D:
	return load("res://Art/items/money_bag_icon.png")


func equip(_player: Player) -> void:
	Enemy.coin_multiplier *= 1.3


func unequip(_player: Player) -> void:
	Enemy.coin_multiplier /= 1.3
