class_name IncreasePlayerMaxHp extends ItemEffect

var _amount: int

func _init(amount: int) -> void:
	self._amount = amount

func enable(player: Player) -> void:
	player.life_component.max_hp += _amount
	player.life_component.hp += _amount

func disable(player: Player) -> void:
	player.life_component.max_hp -= _amount
	player.life_component.hp -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("INCREASE_PLAYER_MAX_HP") % _number_to_string(_amount))
