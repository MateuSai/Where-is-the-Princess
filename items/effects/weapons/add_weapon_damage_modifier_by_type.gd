class_name AddWeaponDamageModifierByType extends ItemEffect

var _type: WeaponData.Type
var _amount: int

func _init(type: WeaponData.Type, amount: int) -> void:
	_type = type
	_amount = amount

func enable(player: Player) -> void:
	player.weapons.add_damage_modifier_by_type(_type, _amount)

func disable(player: Player) -> void:
	player.weapons.remove_damage_modifier_by_type(_type, _amount)

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("WEAPON_DAMAGE_MODIFIER_BY_TYPE") % [_number_to_string(_amount), tr(WeaponData.Type.keys()[_type].to_snake_case().to_upper())])
