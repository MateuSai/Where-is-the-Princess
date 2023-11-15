class_name LeatherArmor extends Armor


func _init() -> void:
	initialize("LEATHER_ARMOR", "LEATHER_ARMOR_DESCRIPTION", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_06.png"), Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png"), Rect2(16, 0, 16, 16)), 4)


func equip(_player: Player) -> void:
	pass


func unequip(_player: Player) -> void:
	pass
