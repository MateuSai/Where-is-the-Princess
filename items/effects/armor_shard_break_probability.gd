class_name ArmorShardBreakProbability extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	_amount = amount

func enable(player: Player) -> void:
	player.armor_shard_break_probability += _amount

func disable(player: Player) -> void:
	player.armor_shard_break_probability -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount <= 0 else RED) % (tr("ARMOR_SHARD_BREAK_PROBABILITY") % _number_to_string(_amount))
