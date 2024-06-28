class_name PlayerExtraWaterDamage extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	self._amount = amount

func enable(player: Player) -> void:
	player.extra_water_damage += _amount

func disable(player: Player) -> void:
	player.extra_water_damage -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 0 else RED) % (("+" if _amount >= 0 else "") + (tr("PLAYER_EXTRA_WATER_DAMAGE") % _amount))