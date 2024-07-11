class_name HealPlayer extends ItemEffect

var _amount: int

func _init(amount: int) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.life_component.hp += _amount

func disable(_player: Player) -> void:
	pass

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("HEAL_PLAYER") % str(_amount))
