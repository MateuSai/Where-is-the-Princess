class_name IronSkin extends PermanentArtifact

func _init() -> void:
	effects = [
		IncreasePlayerBlockProbability.new(30)
	]

#func equip(player: Player) -> void:
#	player.life_component.block_probability += 30

#func unequip(player: Player) -> void:
#	player.life_component.block_probability -= 30

func get_icon() -> Texture2D:
	return load("res://Art/items/stone_skin.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Stone_Skin_UI_desc.png")
