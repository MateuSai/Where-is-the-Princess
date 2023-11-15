class_name FarmerClothes extends Armor


func _init() -> void:
	initialize(2)


func equip(player: Player) -> void:
	player.shop_discount += 0.25


func unequip(player: Player) -> void:
	player.shop_discount -= 0.25


func get_sprite_sheet() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_07.png")


func get_icon() -> Texture:
	return Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png"), Rect2(16, 16, 16, 16))
