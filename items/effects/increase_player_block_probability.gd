class_name IncreasePlayerBlockProbability extends ItemEffect

var _amount: int

func _init(amount: int) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.life_component.block_probability += _amount

func disable(player: Player) -> void:
	player.life_component.block_probability -= _amount