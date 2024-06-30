class_name IncreaseDashStaminaCost extends ItemEffect

var _amount: float

func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.dash_stamina_cost += _amount

func disable(player: Player) -> void:
	player.dash_stamina_cost -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 0 else RED) % (tr("INCREASE_DASH_STAMINA_COST") % _number_to_string(_amount))