class_name PlayerExtraWaterDamage extends ItemEffect

var amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
    self.amount = amount

func enable(player: Player) -> void:
    player.extra_water_damage += amount

func disable(player: Player) -> void:
    player.extra_water_damage -= amount