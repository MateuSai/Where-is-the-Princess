class_name IncreaseWeaponsConditionCostMultiplier extends ItemEffect

var _amount: float

func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.weapons.condition_cost_multiplier += _amount

func disable(player: Player) -> void:
	player.weapons.condition_cost_multiplier -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 0 else RED) % (tr("INCREASE_WEAPONS_CONDITION_COST_MULTIPLIER") % _number_to_string(_amount * 100))