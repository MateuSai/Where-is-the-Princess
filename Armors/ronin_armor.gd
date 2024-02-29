extends Armor


func _init() -> void:
	initialize(4, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_ronin_icon.png") as Texture2D, 5, 3)


func equip(_player: Player) -> void:
	Globals.add_weapon_damage_modifier_by_subtype(WeaponData.Subtype.KATANA, 1)


func unequip(_player: Player) -> void:
	Globals.remove_weapon_damage_modifier_by_subtype(WeaponData.Subtype.KATANA, 1)


func enable_ability_effect(_player: Player) -> void:
	Weapon.attack_animation_speed_modifier *= 1.5


func disable_ability_effect(_player: Player) -> void:
	Weapon.attack_animation_speed_modifier /= 1.5


func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_10.png")


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_10_icon.png") as Texture2D
