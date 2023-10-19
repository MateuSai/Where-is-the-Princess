class_name CommonerClothes extends Armor


func _init() -> void:
	initialize("COMMONER_CLOTHES", "COMMONER_CLOTHES_DESCRIPTION", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_05.png"), 2)


func equip(_player: Player) -> void:
	Globals.add_weapon_damage_modifier_by_type(Weapon.Type.DAGGER, 1)
#	player.weapons.get_child(0).damage += 1


func unequip(_player: Player) -> void:
	Globals.remove_weapon_damage_modifier_by_type(Weapon.Type.DAGGER, 1)
#	player.weapons.get_child(0).damage -= 1
