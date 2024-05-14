class_name CursedAxeRune extends CursedRune

func _init() -> void:
	effects = [
		AddWeaponDamageModifierByType.new(WeaponData.Type.AXE, 2),
		AddConditionCostMultiplierByType.new(WeaponData.Type.AXE, 0.25)
	]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_kapp_icon.png")

func get_symbol() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_kapp.png")
