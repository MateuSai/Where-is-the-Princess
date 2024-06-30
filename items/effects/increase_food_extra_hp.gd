class_name IncreaseFoodExtraHp extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	self._amount = amount

func enable(_player: Player) -> void:
	Globals.global_stats.food_extra_hp += _amount

func disable(_player: Player) -> void:
	Globals.global_stats.food_extra_hp -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("INCREASE_FOOD_EXTRA_HP") % _amount)