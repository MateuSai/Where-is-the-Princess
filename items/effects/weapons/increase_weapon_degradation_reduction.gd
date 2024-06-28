class_name IncreaseWeaponDegradationReduction extends ItemEffect

var _amount: float

func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.weapon_degradation_reduction += _amount

func disable(player: Player) -> void:
	player.weapon_degradation_reduction -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("INCREASE_WEAPON_DEGRADATION_REDUCTION") % str(_amount * 100))