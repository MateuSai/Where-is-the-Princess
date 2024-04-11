class_name HealPlayer extends ItemEffect

var amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
    self.amount = amount

func enable(player: Player) -> void:
    player.life_component.hp += amount

func disable(_player: Player) -> void:
    pass