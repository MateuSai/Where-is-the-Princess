class_name RestoreCurrentWeaponCondition extends ItemEffect

var amount: float

@warning_ignore("shadowed_variable")
func _init(amount: float) -> void:
	self.amount = amount

func enable(player: Player) -> void:
	if not player.weapons.current_weapon is Dagger:
		player.weapons.current_weapon.stats.condition += amount

func disable(_player: Player) -> void:
	pass