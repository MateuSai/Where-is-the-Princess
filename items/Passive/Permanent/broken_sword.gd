extends PermanentPassiveItem

func get_icon() -> Texture2D:
	return load("res://Art/items/broken_sword_icon.png")

func equip(player: Player) -> void:
	player.weapon_degradation_reduction += 0.22

func unequip(player: Player) -> void:
	player.weapon_degradation_reduction -= 0.22

func get_big_icon() -> Texture2D:
	return load("res://Art/items/broken_sword_UI_desc.png")
