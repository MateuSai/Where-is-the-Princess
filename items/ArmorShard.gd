class_name ArmorShard extends Item


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/armor_shard.png")


func can_pick_up(player: Player) -> bool:
	return not player.armor is Underpants and player.armor.condition < player.armor.max_condition


func pick_up(player: Player) -> void:
	if randf_range(0, 100) < player.armor_shard_break_probability:
		return

	super(player)

	player.armor.condition += 1
