class_name PlayerStatistics

var times_killed: int = 0

static func from_dic(dic: Dictionary) -> PlayerStatistics:
	var player_statistics: PlayerStatistics = PlayerStatistics.new()

	for key: String in dic.keys():
		if player_statistics.get(key) != null:
			player_statistics.set(key, dic[key])
		else:
			printerr("Data: Invalid property: " + key)

	return player_statistics

func to_dic() -> Dictionary:
	var dic: Dictionary = {}

	dic["times_killed"] = times_killed

	return dic
