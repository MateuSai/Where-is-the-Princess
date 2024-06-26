class_name IncreaseDashStaminaCost extends ItemEffect

var _amount: float

func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.dash_stamina_cost += _amount

func disable(player: Player) -> void:
	player.dash_stamina_cost -= _amount