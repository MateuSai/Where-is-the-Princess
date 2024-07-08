class_name AdditionalWeaponCarryCapacity extends PlayerUpgrade

func _init() -> void:
	effects = [IncreaseCarryCapacity.new(1)]

#func equip(player: Player) -> void:
#	player.weapons.max_weapons += 1


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/capacity_ITEM_upgrade.png")


func get_dark_soul_cost() -> int:
	return 2
