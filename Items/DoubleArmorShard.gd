class_name DoubleArmorShard extends Item


func get_icon() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/Items/armor_shard_max.png")


func can_pick_up(player: Player) -> bool:
	return not player.armor is NoArmor and player.armor.condition < player.armor.max_condition


func pick_up(player: Player) -> void:
	player.armor.condition += 6
