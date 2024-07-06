class_name AdditionalMaxStamina extends PlayerUpgrade

func _init() -> void:
	effects = [IncreaseMaxStamina.new(10)]

#func equip(player: Player) -> void:
#	player.max_stamina += 10


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Stamina_ITEM_upgrade.png")


func get_dark_soul_cost() -> int:
	return 3


func get_max_amount() -> int:
	return 4
