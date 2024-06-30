class_name IncreasePlayerAcidProgressPerSecond extends ItemEffect

var _amount: float

func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.acid_progress_per_second += _amount

func disable(player: Player) -> void:
	player.acid_progress_per_second -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 0 else RED) % (tr("INCREASE_PLAYER_ACID_PROGRESS_PER_SECOND") % _number_to_string(_amount))