class_name RangedWeaponData extends WeaponData

# Path to projectile scene
@export_file("*.tscn") var projectile_scene_path: String
@export_file var shoot_sound_path: String
@export var normal_attack_projectile_speed: int = 200
@export var ability_projectile_speed: int = 300

static func from_dic(dic: Dictionary) -> RangedWeaponData:
	var weapon_data: RangedWeaponData = RangedWeaponData.new()

	_load_dic(weapon_data, dic)

	return weapon_data

static func _load_dic(weapon_data: WeaponData, dic: Dictionary) -> void:
	super(weapon_data, dic)

	weapon_data.projectile_scene_path = dic.projectile_scene_path
	weapon_data.shoot_sound_path = dic.shoot_sound_path
	weapon_data.normal_attack_projectile_speed = dic.normal_attack_projectile_speed
	weapon_data.ability_projectile_speed = dic.ability_projectile_speed
