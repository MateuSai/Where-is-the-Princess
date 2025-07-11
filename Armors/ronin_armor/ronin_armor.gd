extends Armor

func _init() -> void:
	super(4)

	effects = [AddWeaponDamageModifierBySubtype.new(WeaponData.Subtype.KATANA, 1)]

	_setup_ability(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_ronin_icon.png") as Texture2D, 5, 2.5)

func enable_ability_effect(_player: Player) -> void:
	Globals.global_stats.player_weapons_attack_animation_speed_modifier *= 1.5

func disable_ability_effect(_player: Player) -> void:
	Globals.global_stats.player_weapons_attack_animation_speed_modifier /= 1.5

func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_10.png")

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_10_icon.png") as Texture2D
