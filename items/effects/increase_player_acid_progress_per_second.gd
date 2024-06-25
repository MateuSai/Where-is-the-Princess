class_name IncreasePlayerAcidProgressPerSecond extends ItemEffect

var _amount: float

func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.acid_progress_per_second += _amount

func disable(player: Player) -> void:
	player.acid_progress_per_second -= _amount