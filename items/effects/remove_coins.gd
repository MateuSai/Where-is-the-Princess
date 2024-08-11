class_name RemoveCoins extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.remove_coins(_amount)

func disable(_player: Player) -> void:
	pass

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 0 else RED) % (tr("REMOVE_COINS") % _number_to_string(-_amount))
