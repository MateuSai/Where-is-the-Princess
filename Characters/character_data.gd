class_name CharacterData extends Resource

@export var max_hp: int = 4

@export var mass: float = 1
@export var acceleration: float = 0.4
@export var max_speed: int = 100

@export var flying: bool = false

@export var can_be_knocked_back: bool = true
@export var motionless: bool = false

@export var initial_resistances: int = 0

@export var body_type: LifeComponent.BodyType = LifeComponent.BodyType.FLESH

@export var biomes: PackedStringArray = ["forest"]


static func from_dic(dic: Dictionary) -> CharacterData:
	var character_data: CharacterData = CharacterData.new()

	_load_dic_into_data(dic, character_data)

	return character_data


static func _load_dic_into_data(dic: Dictionary, character_data: CharacterData) -> void:
	character_data.max_hp = dic.max_hp

	character_data.mass = dic.mass
	character_data.acceleration = dic.acceleration
	character_data.max_speed = dic.max_speed
	var flying_int: int = dic.flying
	character_data.flying = bool(flying_int)
	var can_be_knocked_back_int: int = dic.can_be_knocked_back
	character_data.can_be_knocked_back = bool(can_be_knocked_back_int)
	var motionless_int: int = dic.motionless
	character_data.motionless = bool(motionless_int)
	@warning_ignore("int_as_enum_without_cast")
	character_data.body_type = LifeComponent.BodyType.keys().find(dic.body_type)
	character_data.initial_resistances = dic.resistances
	character_data.biomes = dic.biomes.split(",")
