class_name AddWeaponDamageModifierBySubtype extends ItemEffect

var type: WeaponData.Subtype
var amount: int

@warning_ignore("shadowed_variable")
func _init(type: WeaponData.Subtype, amount: int) -> void:
	self.type = type
	self.amount = amount

func enable(player: Player) -> void:
	player.weapons.add_damage_modifier_by_subtype(type, amount)

func disable(player: Player) -> void:
	player.weapons.remove_damage_modifier_by_subtype(type, amount)