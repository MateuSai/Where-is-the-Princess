class_name IncreaseExtraDamageWhenWeaponBreaks extends ItemEffect

var amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
    self.amount = amount

func enable(player: Player) -> void:
    player.weapons.extra_damage_when_weapon_breaks += amount

func disable(player: Player) -> void:
    player.weapons.extra_damage_when_weapon_breaks -= amount