class_name PlayerExtraDamageTaken extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	self._amount = amount

func enable(player: Player) -> void:
	player.life_component.extra_damage_taken += _amount

func disable(player: Player) -> void:
	player.life_component.extra_damage_taken -= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 0 else RED) % (tr("PLAYER_EXTRA_DAMAGE_TAKEN") % _number_to_string(_amount))