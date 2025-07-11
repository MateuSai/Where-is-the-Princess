class_name CursedHammerRune extends CursedRune

func _init() -> void:
	effects = [
		AddWeaponDamageModifierByType.new(WeaponData.Type.HAMMER, 2),
		AddConditionCostMultiplierByType.new(WeaponData.Type.HAMMER, 0.25)
	]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_delt_icon_cursed.png")

func get_symbol() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_delt_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_delt_cursed_ui_desc.png")
