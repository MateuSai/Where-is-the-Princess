class_name CursedSpearRune extends CursedRune

func _init() -> void:
	effects = [
		AddWeaponDamageModifierByType.new(WeaponData.Type.SPEAR, 1),
		AddConditionCostMultiplierByType.new(WeaponData.Type.SPEAR, 0.25)
	]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_lambd_icon_cursed.png")

func get_symbol() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_lambd.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_lambd_cursed_ui_desc.png")