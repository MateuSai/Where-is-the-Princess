class_name AdditionalHeart extends PlayerUpgrade

func _init() -> void:
	effects = [IncreasePlayerMaxHp.new(4)]

#func equip(player: Player) -> void:
#	player.life_component.max_hp += 4
#	player.life_component.hp += 4


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Health_ITEM_upgrade.png")


func get_dark_soul_cost() -> int:
	return 5


func get_max_amount() -> int:
	return 4
