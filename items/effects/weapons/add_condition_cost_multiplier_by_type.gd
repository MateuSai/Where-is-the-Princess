class_name AddConditionCostMultiplierByType extends ItemEffect

var _type: WeaponData.Type
var _amount: float

func _init(type: WeaponData.Type, amount: float) -> void:
	_type = type
	_amount = amount

func enable(player: Player) -> void:
	player.weapons.add_condition_cost_multiplier_by_type(_type, _amount)

func disable(player: Player) -> void:
	player.weapons.add_condition_cost_multiplier_by_type(_type, _amount)

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 0 else RED) % (tr("WEAPON_CONDITION_COST_MULTIPLIER_BY_TYPE") % [str(_amount), tr(WeaponData.Type.keys()[_type].to_snake_case().to_upper())])
