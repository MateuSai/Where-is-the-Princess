class_name ArmorAbilityRechargeTimeReduction extends ItemEffect

var _amount: float

@warning_ignore("shadowed_variable")
func _init(amount: float) -> void:
	self._amount = amount

func enable(player: Player) -> void:
	player.armor_ability_recharge_time_reduction += _amount

func disable(player: Player) -> void:
	player.armor_ability_recharge_time_reduction -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("ARMOR_ABILITY_RECHARGE_TIME_REDUCTION") % str(_amount))
