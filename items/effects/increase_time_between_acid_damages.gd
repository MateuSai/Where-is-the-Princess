class_name IncreaseTimeBetweenAcidDamages extends ItemEffect

var _amount: float

func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.time_between_acid_damages += _amount

func disable(player: Player) -> void:
	player.time_between_acid_damages -= _amount