class_name Statistics

const SAVE_NAME: String = "statistics.json"

var _player_statistics: PlayerStatistics = PlayerStatistics.new()
var _enemies_statistics: Dictionary = {}
var _weapons_statistics: Dictionary = {}
var _items_statistics: Dictionary = {}
var _biomes_statistics: Dictionary = {}

func save() -> void:
	var file: FileAccess = FileAccess.open(SavedData.USER_FOLDER + SAVE_NAME, FileAccess.WRITE)
	if not file:
		printerr("Error opening " + SavedData.USER_FOLDER + SAVE_NAME + " for writing!! I can't save your data, bro")
		return
	file.store_string(JSON.stringify(to_dic(), "\t"))
	file.close()
	#print(JSON.new().stringify(data, "\t"))

static func _load() -> Statistics:
	var file: FileAccess = FileAccess.open(SavedData.USER_FOLDER + SAVE_NAME, FileAccess.READ)
	if file:
		print("Statistics file found. Loading it...")
		var json: JSON = JSON.new()
		json.parse(file.get_as_text())
		if json.data is Dictionary:
			return Statistics.from_dic(json.data as Dictionary)
		else:
			printerr("Could not load file data as json, using default values...")
			return Statistics.new()
	else:
		print("No statistics file found, using default value...")
		return Statistics.new()

func get_player_statistics() -> PlayerStatistics:
	return _player_statistics

func add_player_times_killed() -> void:
	_player_statistics.times_killed += 1

	save()

func get_enemies_statistics() -> Dictionary:
	return _enemies_statistics

func get_enemy_statistics(enemy_id: String) -> EnemyStatistics:
	if _enemies_statistics.has(enemy_id):
		return _enemies_statistics[enemy_id]

	return null

func add_enemy_times_killed(enemy_id: String) -> void:
	if not _enemies_statistics.has(enemy_id):
		_enemies_statistics[enemy_id] = EnemyStatistics.new()

	(_enemies_statistics[enemy_id] as EnemyStatistics).times_killed += 1

	save()

func add_enemy_player_kill(enemy_id: String) -> void:
	if not _enemies_statistics.has(enemy_id):
		_enemies_statistics[enemy_id] = EnemyStatistics.new()

	(_enemies_statistics[enemy_id] as EnemyStatistics).player_kills += 1

	save()

func get_weapons_statistics() -> Dictionary:
	return _weapons_statistics

func get_weapon_statistics(id: String) -> WeaponStatistics:
	if _weapons_statistics.has(id):
		return _weapons_statistics[id]

	return null

func add_weapon_kill(weapon_id: String) -> void:
	if not _weapons_statistics.has(weapon_id):
		_weapons_statistics[weapon_id] = WeaponStatistics.new()

	(_weapons_statistics[weapon_id] as WeaponStatistics).enemies_killed += 1

	save()

func add_weapon_times_picked_up(weapon_id: String) -> void:
	if not _weapons_statistics.has(weapon_id):
		_weapons_statistics[weapon_id] = WeaponStatistics.new()

	(_weapons_statistics[weapon_id] as WeaponStatistics).times_picked_up += 1

	save()

func get_items_statistics() -> Dictionary:
	return _items_statistics

func get_item_statistics(id: String) -> ItemStatistics:
	if _items_statistics.has(id):
		return _items_statistics[id]

	return null

func add_item_times_picked_up(id: String) -> void:
	if not _items_statistics.has(id):
		_items_statistics[id] = ItemStatistics.new()

	(_items_statistics[id] as ItemStatistics).times_picked_up += 1

	save()

func get_biomes_statistics() -> Dictionary:
	return _biomes_statistics

func get_biome_statistics(id: String) -> BiomeStatistics:
	if _biomes_statistics.has(id):
		return _biomes_statistics[id]

	return null

func add_biome_times_entered(name: String) -> void:
	var id: String = name.to_lower()

	if not _biomes_statistics.has(id):
		_biomes_statistics[id] = BiomeStatistics.new()

	(_biomes_statistics[id] as BiomeStatistics).times_entered += 1

	save()

static func from_dic(dic: Dictionary) -> Statistics:
	var statistics: Statistics = Statistics.new()

	for key: String in dic.keys():
		if statistics.get(key) != null:
			if key == "_player_statistics":
				statistics._player_statistics = PlayerStatistics.from_dic(dic._player_statistics)
			elif key == "_enemies_statistics":
				for enemy_id: String in dic._enemies_statistics.keys():
					statistics._enemies_statistics[enemy_id] = EnemyStatistics.from_dic(dic._enemies_statistics[enemy_id])
			elif key == "_weapons_statistics":
				for weapon_id: String in dic._weapons_statistics.keys():
					statistics._weapons_statistics[weapon_id] = WeaponStatistics.from_dic(dic._weapons_statistics[weapon_id])
			elif key == "_items_statistics":
				for item_id: String in dic._items_statistics.keys():
					statistics._items_statistics[item_id] = ItemStatistics.from_dic(dic._items_statistics[item_id])
			elif key == "_biomes_statistics":
				for biome_name: String in dic._biomes_statistics.keys():
					statistics._biomes_statistics[biome_name] = BiomeStatistics.from_dic(dic._biomes_statistics[biome_name])
			else:
				statistics.set(key, dic[key])
		else:
			printerr("Data: Invalid property: " + key)

	return statistics

func to_dic() -> Dictionary:
	var dic: Dictionary = {}

	for property_dic: Dictionary in get_property_list():
		assert(property_dic.name is String)
		var property_name: StringName = property_dic.name
		if property_name in ["RefCounted", "script", "Built-in script", "statistics.gd"]:
			continue
		match property_name:
			"_player_statistics":
				dic["_player_statistics"] = get_player_statistics().to_dic()
			"_enemies_statistics":
				dic["_enemies_statistics"] = {}
				for enemy_id: String in _enemies_statistics.keys():
					dic["_enemies_statistics"][enemy_id] = get_enemy_statistics(enemy_id).to_dic()
			"_weapons_statistics":
				dic["_weapons_statistics"] = {}
				for weapon_id: String in _weapons_statistics.keys():
					dic["_weapons_statistics"][weapon_id] = get_weapon_statistics(weapon_id).to_dic()
			"_items_statistics":
				dic["_items_statistics"] = {}
				for item_id: String in _items_statistics.keys():
					dic["_items_statistics"][item_id] = get_item_statistics(item_id).to_dic()
			"_biomes_statistics":
				dic["_biomes_statistics"] = {}
				for biome_name: String in _biomes_statistics.keys():
					dic["_biomes_statistics"][biome_name] = get_biome_statistics(biome_name).to_dic()
			_:
				dic[property_name] = get(property_name)

	return dic
