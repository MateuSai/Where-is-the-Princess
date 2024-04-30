class_name IncreaseCoinMultiplier extends ItemEffect

var amount: float

@warning_ignore("shadowed_variable")
func _init(amount: float) -> void:
    self.amount = amount

func enable(_player: Player) -> void:
    Enemy.coin_multiplier *= amount

func disable(_player: Player) -> void:
    Enemy.coin_multiplier /= amount