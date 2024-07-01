class_name CommonerClothes extends Armor

func _init() -> void:
	effects = [AddWeaponDamageModifierByType.new(WeaponData.Type.DAGGER, 1)]

	initialize(2)

func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_05.png")

func get_icon() -> Texture2D:
	return Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png") as Texture2D, Rect2(0, 48, 16, 16))
