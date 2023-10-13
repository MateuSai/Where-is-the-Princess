class_name CommonerClothes extends Armor


func _init() -> void:
	initialize("COMMONER_CLOTHES", "MERCENARY_ARMOR_DESCRIPTION", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_05.png"), 2)


func equip(player: Player) -> void:
	player.weapons.get_child(0).damage += 1


func unequip(player: Player) -> void:
	player.weapons.get_child(0).damage -= 1
