class_name EnemyData extends CharacterData


@export var icon: Texture2D = null

@export var min_coins: int = 2
@export var max_coins: int = 3
@export var min_souls: int = 1
@export var max_souls: int = 1
@export var min_dark_souls: int = 0
@export var max_dark_souls: int = 0
@export_range(0.0, 1.0) var food_prob: float = 0.1
@export_range(0.0, 1.0) var armor_shard_prob: float = 0.1


static func from_dic(dic: Dictionary) -> EnemyData:
	var enemy_data: EnemyData = EnemyData.new()

	_load_dic_into_data(dic, enemy_data)

	enemy_data.icon = load(dic.icon)

	var splitted_coins: PackedStringArray = str(dic.coins).split("-")
	enemy_data.min_coins = int(splitted_coins[0])
	enemy_data.max_coins = int(splitted_coins[0 if splitted_coins.size() == 1 else 1])

	var splitted_souls: PackedStringArray = str(dic.souls).split("-")
	enemy_data.min_souls = int(splitted_souls[0])
	enemy_data.max_souls = int(splitted_souls[0 if splitted_souls.size() == 1 else 1])

	var splitted_dark_souls: PackedStringArray = str(dic.dark_souls).split("-")
	enemy_data.min_dark_souls = int(splitted_dark_souls[0])
	enemy_data.max_dark_souls = int(splitted_dark_souls[0 if splitted_dark_souls.size() == 1 else 1])

	enemy_data.food_prob = dic.food_prob
	enemy_data.armor_shard_prob = dic.armor_shard_prob

	return enemy_data
