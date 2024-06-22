class_name MeleeRune extends Rune

func _init() -> void:
	effects = [
		AddWeaponDamageModifierByType.new(WeaponData.Type.SPEAR, 1),
		AddWeaponDamageModifierByType.new(WeaponData.Type.SWORD, 1),
		AddWeaponDamageModifierByType.new(WeaponData.Type.HAMMER, 1),
		AddWeaponDamageModifierByType.new(WeaponData.Type.DAGGER, 1),
		AddWeaponDamageModifierByType.new(WeaponData.Type.AXE, 1),
		AddWeaponDamageModifierByType.new(WeaponData.Type.OTHER, 1)
	]

func get_quality() -> Quality:
	return Quality.CHINGON

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omega_icon.png") as Texture2D

func get_symbol() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omega.png") as Texture2D

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/rune_omega_ui_desc.png")