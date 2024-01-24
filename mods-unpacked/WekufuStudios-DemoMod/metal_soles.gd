class_name MetalSoles extends PermanentPassiveItem


func equip(player: Player) -> void:
	player.add_resistance(Character.Resistance.ACID)


func unequip(player: Player) -> void:
	player.remove_resistance(Character.Resistance.ACID)


func get_icon() -> Texture2D:
	return load("res://icon.png")
