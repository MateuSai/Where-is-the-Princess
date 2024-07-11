class_name IncreasePlayerBlockProbability extends ItemEffect

var _amount: int

func _init(amount: int) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.life_component.block_probability += _amount

func disable(player: Player) -> void:
	player.life_component.block_probability -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("INCREASE_PLAYER_BLOCK_PROBABILITY") % _number_to_string(_amount))
