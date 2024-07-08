class_name IncreaseCarryCapacity extends ItemEffect

var _amount: int

func _init(amount: int) -> void:
	self._amount = amount

func enable(player: Player) -> void:
	player.weapons.max_weapons += _amount

func disable(player: Player) -> void:
	player.weapons.max_weapons -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("INCREASE_CARRY_CAPACITY") % _number_to_string(_amount))
