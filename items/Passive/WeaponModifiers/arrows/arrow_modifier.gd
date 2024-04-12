class_name ArrowModifier extends WeaponModifier

var type: Arrow.Type


func equip_to_weapon(weapon: Weapon) -> void:
	assert(weapon is BowOrCrossbowWeapon)
	weapon.arrow_type = type


func unequip_from_weapon(weapon: Weapon) -> void:
	assert(weapon is BowOrCrossbowWeapon)
#	weapon.arrow_type = type


func can_pick_up(player: Player) -> bool:
	return player.weapons.current_weapon is BowOrCrossbowWeapon


func get_icon() -> Texture2D:
	return Arrow.TEXTURES[type]

#
#func pick_up(player: Player) -> void:
#
#	super(player)
