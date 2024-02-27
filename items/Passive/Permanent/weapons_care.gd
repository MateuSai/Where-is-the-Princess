extends PermanentPassiveItem


func get_icon() -> Texture2D:
	return load("res://Art/items/big_ration_icon.png")


func equip(player: Player) -> void:
	player.weapon_degradation_reduction += 0.22


func unequip(player: Player) -> void:
	player.weapon_degradation_reduction -= 0.22
