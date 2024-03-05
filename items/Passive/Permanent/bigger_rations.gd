extends PermanentPassiveItem


func equip(_player: Player) -> void:
	Food.extra_hp += 1


func unequip(_player: Player) -> void:
	Food.extra_hp -= 1


func get_icon() -> Texture2D:
	return load("res://Art/items/big_ration_icon.png")


func get_big_icon() -> Texture2D:
	return load("res://Art/items/big_ration_UI_desc.png")
