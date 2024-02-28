extends Armor


func _init() -> void:
	initialize(4, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_plague_icon.png") as Texture2D, 5, 3)


func equip(player: Player) -> void:
	Globals.add_weapon_damage_modifier_by_subtype(WeaponData.Subtype.KATANA, 1)


func unequip(player: Player) -> void:
	Globals.remove_weapon_damage_modifier_by_subtype(WeaponData.Subtype.KATANA, 1)


func enable_ability_effect(player: Player) -> void:
	Weapon.attack_animation_speed_modifier *= 2.0


func disable_ability_effect(_player: Player) -> void:
	Weapon.attack_animation_speed_modifier /= 2.0


func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_09.png")


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_09_icon.png") as Texture2D
