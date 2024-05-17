class_name DamagePlayerArmor extends ItemEffect

var amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
    self.amount = amount

func enable(player: Player) -> void:
    if not player.armor is Underpants:
        player.life_component.take_damage(amount, Vector2.ZERO, 0, null, player, player.id)

func disable(_player: Player) -> void:
    pass