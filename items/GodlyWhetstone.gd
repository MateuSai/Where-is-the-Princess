class_name GodlyWhetstone extends Item


func get_icon() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/whetstone_max.png")


func can_pick_up(player: Player) -> bool:
	return player.weapons.current_weapon.get_index() > 0 and player.weapons.current_weapon.stats.condition < 100


func pick_up(player: Player) -> void:
	player.weapons.current_weapon.stats.set_condition(100)
