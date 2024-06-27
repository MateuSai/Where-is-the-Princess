class_name DamagePlayer extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	self._amount = amount

func enable(player: Player) -> void:
	player.life_component.take_damage(_amount, Vector2.ZERO, 0, null, player, player.id)

func disable(_player: Player) -> void:
	pass

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 0 else RED) % (tr("DAMAGE_PLAYER") % str(_amount))