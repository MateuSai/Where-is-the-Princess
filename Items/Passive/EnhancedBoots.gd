class_name EnhancedBoots extends PassiveItem


func _init() -> void:
	initialize(load("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/bag_coins.png"))


func equip(player: Player) -> void:
	player.max_speed += 100


func unequip(player: Player) -> void:
	player.max_speed -= 100
