class_name IncreaseTimeBetweenAcidDamages extends ItemEffect

var _amount: float

func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.time_between_acid_damages += _amount

func disable(player: Player) -> void:
	player.time_between_acid_damages -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("INCREASE_TIME_BETWEEN_ACID_DAMAGES") % str(_amount))