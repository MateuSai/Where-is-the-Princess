class_name Statistics


var _enemies_statistics: Dictionary = {}


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


func add_enemy_player_kill(enemy_id: String) -> void:
	if not _enemies_statistics.has(enemy_id):
		_enemies_statistics[enemy_id] = EnemyStatistics.new()

	(_enemies_statistics[enemy_id] as EnemyStatistics).player_kills += 1


static func from_dic(dic: Dictionary) -> Statistics:
	var statistics: Statistics = Statistics.new()

	for key: String in dic.keys():
		if statistics.get(key) != null:
			if key == "_enemies_statistics":
				for enemy_id: String in dic._enemies_statistics.keys():
					statistics._enemies_statistics[enemy_id] = EnemyStatistics.from_dic(dic._enemies_statistics[enemy_id])
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
			"_enemies_statistics":
				dic["_enemies_statistics"] = {}
				for enemy_id: String in _enemies_statistics.keys():
					dic["_enemies_statistics"][enemy_id] = get_enemy_statistics(enemy_id).to_dic()
			_:
				dic[property_name] = get(property_name)

	return dic
