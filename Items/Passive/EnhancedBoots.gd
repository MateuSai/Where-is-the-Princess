class_name EnhancedBoots extends PermanentPassiveItem


func _init() -> void:
	_initialize(load("res://Art/items/boots_player.png"))


func equip(player: Player) -> void:
	player.max_speed += 100


func unequip(player: Player) -> void:
	player.max_speed -= 100
