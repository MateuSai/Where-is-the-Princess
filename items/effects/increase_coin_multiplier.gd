class_name IncreaseCoinMultiplier extends ItemEffect

var _amount: float

@warning_ignore("shadowed_variable")
func _init(amount: float) -> void:
	self._amount = amount

func enable(_player: Player) -> void:
	Enemy.coin_multiplier *= _amount

func disable(_player: Player) -> void:
	Enemy.coin_multiplier /= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 1 else RED) % (tr("INCREASE_COIN_MULTIPLIER") % _number_to_string((_amount - 1) * 100))