class_name CharacterData extends Resource

@export var max_hp: int = 4

@export var mass: float = 1
@export var acceleration: float = 0.2
@export var max_speed: int = 100

@export var flying: bool = false: set = set_flying

@export var can_be_knocked_back: bool = true
@export var motionless: bool = false

@export var initial_resistances: int = 0

@export var body_type: LifeComponent.BodyType = LifeComponent.BodyType.FLESH


static func from_dic(dic: Dictionary) -> CharacterData:
	var character_dic: CharacterData = CharacterData.new()

	character_dic.max_hp = dic.max_hp
	character_dic.hp = dic.max_hp

	character_dic.mass = dic.mass
	character_dic.acceleration = dic.acceleration
	character_dic.max_speed = dic.max_speed
	var flying_int: int = dic.flying
	character_dic.flying = bool(flying_int)
	var can_be_knocked_back_int: int = dic.can_be_knocked_back
	character_dic.can_be_knocked_back = bool(can_be_knocked_back_int)
	var motionless_int: int = dic.motionless
	character_dic.motionless = bool(motionless_int)
	@warning_ignore("int_as_enum_without_cast")
	character_dic.body_type = LifeComponent.BodyType.keys().find(dic.body_type)
	character_dic.initial_resistances = dic.resistances

	return character_dic


func set_flying(new_value: bool) -> void:
	flying = new_value
