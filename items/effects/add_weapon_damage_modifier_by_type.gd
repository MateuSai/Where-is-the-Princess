class_name AddWeaponDamageModifierByType extends ItemEffect

var type: WeaponData.Type
var amount: int

func _init(type: WeaponData.Type, amount: int) -> void:
	self.type = type
	self.amount = amount

func enable(_player: Player) -> void:
	Globals.add_weapon_damage_modifier_by_type(type, amount)

func disable(_player: Player) -> void:
	Globals.remove_weapon_damage_modifier_by_type(type, amount)