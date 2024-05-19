class_name AddConditionCostMultiplierByType extends ItemEffect

var type: WeaponData.Type
var amount: float

@warning_ignore("shadowed_variable")
func _init(type: WeaponData.Type, amount: float) -> void:
	self.type = type
	self.amount = amount

func enable(player: Player) -> void:
	player.weapons.add_condition_cost_multiplier_by_type(type, amount)

func disable(player: Player) -> void:
	player.weapons.add_condition_cost_multiplier_by_type(type, amount)