class_name IncreaseThrowSpread extends ItemEffect

var amount: float

@warning_ignore("shadowed_variable")
func _init(amount: float) -> void:
	self.amount = amount

func enable(player: Player) -> void:
	player.weapons.throw_spread += amount

func disable(player: Player) -> void:
	player.weapons.throw_spread -= amount