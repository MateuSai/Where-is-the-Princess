class_name ToughSkin extends PermanentPassiveItem


#func _init() -> void:
#	_initialize(load("res://Art/obstacles and dangers/saw.png"))


func equip(player: Player) -> void:
	player.life_component.block_probability += 30


func unequip(player: Player) -> void:
	player.life_component.block_probability -= 30


func get_icon() -> Texture:
	return load("res://Art/obstacles and dangers/saw.png")
