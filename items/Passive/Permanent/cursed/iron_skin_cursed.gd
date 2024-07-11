class_name IronSkinCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [
		IncreasePlayerBlockProbability.new(45),
		IncreasePlayerMaxSpeed.new( - 40)
	]

#func equip(player: Player) -> void:
#	player.life_component.block_probability += 45

#	player.data.max_speed -= 40

#func unequip(player: Player) -> void:
#	player.life_component.block_probability -= 45

#	player.data.max_speed += 40

func get_icon() -> Texture2D:
	return load("res://Art/items/stone_skin_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Stone_Skin_cursed_UI_desc.png")
