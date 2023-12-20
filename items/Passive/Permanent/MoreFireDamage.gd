class_name MoreFiredamage extends PermanentPassiveItem


func _init() -> void:
	pass
	#icon = null
	#icon = load("res://Art/items/boots_player.png")
	#_initialize(load("res://Art/items/boots_player.png"))


func equip(player: Player) -> void:
	player.extra_fire_damage += 1


func unequip(player: Player) -> void:
	player.extra_fire_damage -= 1


func get_icon() -> Texture2D:
	return load("res://Art/items/boots_icon.png")
