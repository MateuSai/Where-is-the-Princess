class_name IncreaseExtraDamageWhenWeaponBreaks extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	self._amount = amount

func enable(player: Player) -> void:
	player.weapons.extra_damage_when_weapon_breaks += _amount

func disable(player: Player) -> void:
	player.weapons.extra_damage_when_weapon_breaks -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("INCREASE_EXTRA_DAMAGE_WHEN_WEAPON_BREAKS") % _amount)