extends PermanentPassiveItem


func equip(player: Player) -> void:
	player.acid_progress_per_second *= 0.5
	#player.add_resistance(Character.Resistance.ACID)


func unequip(player: Player) -> void:
	player.acid_progress_per_second *= 2
	#player.remove_resistance(Character.Resistance.ACID)


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Acid_resist_ring.png")
