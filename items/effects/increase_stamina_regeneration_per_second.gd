class_name IncreaseStaminaRegenerationPerSecond extends ItemEffect

var amount: float

@warning_ignore("shadowed_variable")
func _init(amount: float) -> void:
    self.amount = amount

func enable(player: Player) -> void:
    player.stamina_regeneration_per_second += amount

func disable(player: Player) -> void:
    player.stamina_regeneration_per_second -= amount