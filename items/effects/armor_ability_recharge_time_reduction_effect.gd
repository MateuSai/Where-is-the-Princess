class_name ArmorAbilityRechargeTimeReduction extends ItemEffect

var amount: float

@warning_ignore("shadowed_variable")
func _init(amount: float) -> void:
	self.amount = amount


func enable(player: Player) -> void:
	player.armor_ability_recharge_time_reduction += amount


func disable(player: Player) -> void:
	player.armor_ability_recharge_time_reduction -= amount
