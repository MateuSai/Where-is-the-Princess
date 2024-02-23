extends PermanentPassiveItem


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/soul_amulet.png")


func equip(_player: Player) -> void:
	Projectile.non_player_projectile_speed_multiplier -= 0.9


func unequip(_player: Player) -> void:
	Projectile.non_player_projectile_speed_multiplier += 0.9
