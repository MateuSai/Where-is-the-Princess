class_name IncreaseFoodExtraHp extends ItemEffect

var amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
    self.amount = amount

func enable(_player: Player) -> void:
    Food.extra_hp += amount

func disable(_player: Player) -> void:
    Food.extra_hp -= amount