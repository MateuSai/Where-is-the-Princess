class_name WeaponDamageMultiplier extends ItemEffect

var _amount: float

@warning_ignore("shadowed_variable")
func _init(amount: float) -> void:
	self._amount = amount

func enable(player: Player) -> void:
	player.damage_multiplier *= _amount

func disable(player: Player) -> void:
	player.damage_multiplier /= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 1 else RED) % (tr("WEAPON_DAMAGE_MULTIPLIER") % str((_amount - 1) * 100))