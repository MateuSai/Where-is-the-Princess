class_name IncreasePlayerMaxSpeed extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	self._amount = amount

func enable(player: Player) -> void:
	player.data.max_speed += _amount

func disable(player: Player) -> void:
	player.data.max_speed -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("INCREASE_PLAYER_MAX_SPEED") % _number_to_string(_amount))