class_name MeteorStone extends PermanentPassiveItem


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/meteoric_stone.png")


func equip(player: Player) -> void:
	player.armor_ability_recharge_time_reduction += 0.4
