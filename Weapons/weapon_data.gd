class_name WeaponData extends Resource

enum Type {
	SPEAR,
	SWORD,
	HAMMER,
	DAGGER,
	AXE,

	BOW,
	CROSSBOW,
}
@export var type: Type
@export var weapon_name: String = ""
@export var description: String = ""
@export var weapon_texture: Texture2D = null
@export var icon: Texture2D = null ## 16x16 weapon icon, the one that appears on the bottom of the screen

@export var stamina_cost_per_normal_attack: float = 10
@export var condition_cost_per_normal_attack: float = 5

@export var animation_library: String = ""

@export_group("Active Ability")
@export var active_ability_icon: Texture ## Icon of the weapon's active ability
@export var stamina_to_activate_active_ability: float = 20
@export var souls_to_activate_ability: int = 3 ## The souls you need to collect in order to activate the ability
@export_range(0.0, 100.0) var active_ability_condition_cost: float = 10 ## The weapon condition will decrease this amount after using the ability. Remember all the weapons have 100 condition initially
@export var ability_damage: int = 2: set = set_ability_damage
@export var ability_knockback: int = 300: set = set_ability_knockback
@export_group("")

@export var damage: int = 1: set = set_damage
@export var knockback: int = 300: set = set_knockback


static func from_dic(dic: Dictionary) -> WeaponData:
	var weapon_data: WeaponData = WeaponData.new()

	weapon_data.weapon_name = dic["name"]
	var weapon_texture_path: String = dic["weapon_texture"]
	weapon_data.weapon_texture = load(weapon_texture_path) as Texture2D
	var icon_path: String = dic["icon"]
	weapon_data.icon = load(icon_path) as Texture2D
	weapon_data.type = Type.values()[Type.keys().find(dic["type"])]
	#animation_library = load(ANIMATION_LIBRARIES_FOLDER.path_join(data["animation_library"]))
	weapon_data.animation_library = dic["animation_library"] + "_animation_library"
	weapon_data.damage = dic.damage
	weapon_data.knockback = dic.knockback
	weapon_data.ability_damage = dic.ability_damage
	weapon_data.ability_knockback = dic.ability_knockback
	weapon_data.stamina_cost_per_normal_attack = dic.stamina_cost_per_normal_attack
	weapon_data.condition_cost_per_normal_attack = dic.condition_cost_per_normal_attack
	var ability_icon_path: String = dic["ability_icon"]
	if FileAccess.file_exists(ability_icon_path):
		weapon_data.active_ability_icon = load(ability_icon_path)
	else:
		weapon_data.active_ability_icon = null
	weapon_data.souls_to_activate_ability = dic["souls_to_activate_ability"]
	weapon_data.active_ability_condition_cost = dic["ability_condition_cost"]

	return weapon_data


func set_damage(new_damage: int) -> void:
	damage = new_damage


func set_ability_damage(new_ability_damage: int) -> void:
	ability_damage = new_ability_damage


func set_knockback(new_knockback: int) -> void:
	knockback = new_knockback


func set_ability_knockback(new_ability_knockback: int) -> void:
	ability_knockback = new_ability_knockback
