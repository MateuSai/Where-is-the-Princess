class_name AddWeaponDamageModifierByType extends ItemEffect

var type: WeaponData.Type
var amount: int

@warning_ignore("shadowed_variable")
func _init(type: WeaponData.Type, amount: int) -> void:
	self.type = type
	self.amount = amount

func enable(player: Player) -> void:
	player.weapons.add_damage_modifier_by_type(type, amount)

func disable(player: Player) -> void:
	player.weapons.remove_damage_modifier_by_type(type, amount)