class_name FarmerClothes extends Armor

func _init() -> void:
	initialize(2)

func equip(player: Player) -> void:
	super(player)

	player.shop_discount += 0.25

func unequip(player: Player) -> void:
	super(player)

	player.shop_discount -= 0.25

func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_07.png")

func get_icon() -> Texture2D:
	return Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png") as Texture2D, Rect2(16, 16, 16, 16))
