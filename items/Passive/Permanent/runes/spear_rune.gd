class_name SpearRune extends Rune

func _init() -> void:
	effects = [AddWeaponDamageModifierByType.new(WeaponData.Type.SPEAR, 1)]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_lambd_icon.png")

func get_symbol() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_lambd.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_lambd_ui_desc.png")