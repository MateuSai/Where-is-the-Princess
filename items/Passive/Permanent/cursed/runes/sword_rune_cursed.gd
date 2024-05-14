class_name CursedSwordRune extends CursedRune

func _init() -> void:
	effects = [
		AddWeaponDamageModifierByType.new(WeaponData.Type.SWORD, 1),
		AddConditionCostMultiplierByType.new(WeaponData.Type.SWORD, 0.25)
	]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_alf_icon.png")

func get_symbol() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_alf.png")
