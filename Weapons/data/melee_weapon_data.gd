class_name MeleeWeaponData extends WeaponData

## This variable indicates wheter the number of normal attacks. They will be used on order. If it has value 2 but only has one attack animation, for the second attack it will use the first animation but backwards, this is used on the Katana for example
@export var num_normal_attacks: int = 1
@export var increase_num_normal_attacks_on_ability: bool = false
@export var invert_scale_when_looking_left: bool = false


static func from_dic(dic: Dictionary) -> MeleeWeaponData:
	var weapon_data: MeleeWeaponData = MeleeWeaponData.new()

	_load_dic(weapon_data, dic)

	return weapon_data


static func _load_dic(weapon_data: WeaponData, dic: Dictionary) -> void:
	super(weapon_data, dic)

	weapon_data.num_normal_attacks = dic.num_normal_attacks
	weapon_data.increase_num_normal_attacks_on_ability = bool(dic.increase_num_normal_attacks_on_ability)
	weapon_data.invert_scale_when_looking_left = bool(dic.invert_scale_when_looking_left)
