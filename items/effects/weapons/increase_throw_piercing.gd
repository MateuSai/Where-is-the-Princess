class_name IncreaseThrowPiercing extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.throw_piercing += _amount

func disable(player: Player) -> void:
	player.throw_piercing -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("INCREASE_THROW_PIERCING") % _number_to_string(_amount))
