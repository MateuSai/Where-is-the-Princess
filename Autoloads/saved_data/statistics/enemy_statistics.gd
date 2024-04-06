class_name EnemyStatistics

var times_killed: int = 0
var player_kills: int = 0


static func from_dic(dic: Dictionary) -> EnemyStatistics:
	var enemy_statistics: EnemyStatistics = EnemyStatistics.new()

	for key: String in dic.keys():
		if enemy_statistics.get(key) != null:
			enemy_statistics.set(key, dic[key])
		else:
			printerr("Data: Invalid property: " + key)

	return enemy_statistics

func to_dic() -> Dictionary:
	var dic: Dictionary = {}

	dic["times_killed"] = times_killed
	dic["player_kills"] = player_kills

	return dic
