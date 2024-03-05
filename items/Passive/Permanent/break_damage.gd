class_name BreakDamage extends PermanentPassiveItem


func get_icon() -> Texture2D:
	return load("res://Art/items/broken_sword_icon.png")


func equip(player: Player) -> void:
	player.weapons.double_damage_when_weapon_breaks = true


func unequip(player: Player) -> void:
	player.weapons.double_damage_when_weapon_breaks += false
