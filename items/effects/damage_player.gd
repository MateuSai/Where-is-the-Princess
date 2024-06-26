class_name DamagePlayer extends ItemEffect

var _amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
    self._amount = amount

func enable(player: Player) -> void:
    player.life_component.take_damage(_amount, Vector2.ZERO, 0, null, player, player.id)

func disable(_player: Player) -> void:
    pass
