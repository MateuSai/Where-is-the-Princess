extends PermanentPassiveItem


func equip(player: Player) -> void:
	player.time_between_acid_damages += 0.3
	#player.add_resistance(Character.Resistance.ACID)


func unequip(player: Player) -> void:
	player.time_between_acid_damages -= 0.3
	#player.remove_resistance(Character.Resistance.ACID)


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Acid_resist_ring.png")
