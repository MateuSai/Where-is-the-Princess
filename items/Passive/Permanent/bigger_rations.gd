extends PermanentPassiveItem


func get_icon() -> Texture2D:
	return load("res://Art/items/big_ration_icon.png")


func equip(_player: Player) -> void:
	Food.extra_hp += 1


func unequip(_player: Player) -> void:
	Food.extra_hp -= 1
