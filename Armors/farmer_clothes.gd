class_name FarmerClothes extends Armor


func _init() -> void:
	initialize("FARMER_CLOTHES", "FARMER_CLOTHES_DESCRIPTION", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_07.png"), Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png"), Rect2(16, 16, 16, 16)), 2)


func equip(player: Player) -> void:
	player.shop_discount += 0.25


func unequip(player: Player) -> void:
	player.shop_discount -= 0.25
