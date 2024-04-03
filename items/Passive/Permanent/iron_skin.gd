class_name IronSkin extends PermanentPassiveItem

#func _init() -> void:
#	_initialize(load("res://Art/obstacles and dangers/saw.png"))

func equip(player: Player) -> void:
	player.life_component.block_probability += 30

func unequip(player: Player) -> void:
	player.life_component.block_probability -= 30

func get_icon() -> Texture2D:
	return load("res://Art/items/stone_skin.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Stone_Skin_UI_desc.png")