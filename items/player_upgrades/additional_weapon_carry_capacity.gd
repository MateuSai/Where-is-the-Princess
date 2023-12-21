class_name AdditionalWeaponCarryCapacity extends PlayerUpgrade


func equip(player: Player) -> void:
	player.weapons.max_weapons += 1


func get_icon() -> Texture2D:
	return load("res://Art/Dust.png")
