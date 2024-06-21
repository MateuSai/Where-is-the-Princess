class_name CursedMeleeRune extends CursedRune

func _init() -> void:
	effects = [
		AddWeaponDamageModifierByType.new(WeaponData.Type.SPEAR, 2),
		AddWeaponDamageModifierByType.new(WeaponData.Type.SWORD, 2),
		AddWeaponDamageModifierByType.new(WeaponData.Type.HAMMER, 2),
		AddWeaponDamageModifierByType.new(WeaponData.Type.DAGGER, 2),
		AddWeaponDamageModifierByType.new(WeaponData.Type.AXE, 2),
		AddWeaponDamageModifierByType.new(WeaponData.Type.OTHER, 2),

		AddConditionCostMultiplierByType.new(WeaponData.Type.SPEAR, 0.25),
		AddConditionCostMultiplierByType.new(WeaponData.Type.SWORD, 0.25),
		AddConditionCostMultiplierByType.new(WeaponData.Type.HAMMER, 0.25),
		AddConditionCostMultiplierByType.new(WeaponData.Type.DAGGER, 0.25),
		AddConditionCostMultiplierByType.new(WeaponData.Type.AXE, 0.25),
		AddConditionCostMultiplierByType.new(WeaponData.Type.OTHER, 0.25),
	]

func get_quality() -> Quality:
	return Quality.CHINGON

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omega_icon.png") as Texture2D

func get_symbol() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omega.png") as Texture2D

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omega_ui_desc.png")