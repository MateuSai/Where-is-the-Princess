class_name BiomeStatistics

var times_entered: int = 0

static func from_dic(dic: Dictionary) -> BiomeStatistics:
	var biome_statistics: BiomeStatistics = BiomeStatistics.new()

	for key: String in dic.keys():
		if biome_statistics.get(key) != null:
			biome_statistics.set(key, dic[key])
		else:
			printerr("Data: Invalid property: " + key)

	return biome_statistics

func to_dic() -> Dictionary:
	var dic: Dictionary = {}

	dic["times_entered"] = times_entered

	return dic
