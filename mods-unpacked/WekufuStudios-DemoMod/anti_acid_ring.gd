extends PermanentPassiveItem

func _init() -> void:
	effects = [
		IncreaseTimeBetweenAcidDamages.new(0.3)
	]

#func equip(player: Player) -> void:
#	player.time_between_acid_damages += 0.3
	#player.add_resistance(Character.Resistance.ACID)

#func unequip(player: Player) -> void:
#	player.time_between_acid_damages -= 0.3
	#player.remove_resistance(Character.Resistance.ACID)

func get_cursed_version_path() -> String:
	return "res://mods-unpacked/WekufuStudios-DemoMod/anti_acid_ring_cursed.gd"

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Acid_resist_ring.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Acid_resist_ring_UI_desc.png")