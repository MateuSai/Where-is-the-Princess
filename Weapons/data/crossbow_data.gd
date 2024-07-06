class_name CrossbowData extends RangedWeaponData

@export var reload_stamina: float = 10

static func from_dic(dic: Dictionary) -> CrossbowData:
	var weapon_data: CrossbowData = CrossbowData.new()

	_load_dic(weapon_data, dic)

	return weapon_data

static func _load_dic(weapon_data: WeaponData, dic: Dictionary) -> void:
	super(weapon_data, dic)

	weapon_data.reload_stamina = dic.reload_stamina
