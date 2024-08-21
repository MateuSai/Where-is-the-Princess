class_name IncreaseThrowSpread extends ItemEffect

var _amount: float

@warning_ignore("shadowed_variable")
func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.weapons.throw_spread += _amount

func disable(player: Player) -> void:
	player.weapons.throw_spread -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount <= 0 else RED) % (tr("INCREASE_THROW_SPREAD") % _number_to_string(_amount))
