class_name LeatherArmor extends Armor

func _init() -> void:
	initialize(4)

func equip(player: Player) -> void:
	super(player)

func unequip(player: Player) -> void:
	super(player)

func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_06.png")

func get_icon() -> Texture2D:
	return Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png") as Texture2D, Rect2(16, 0, 16, 16))
