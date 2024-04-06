class_name WeaponStatistics

var enemies_killed: int = 0
var times_picked_up: int = 0


static func from_dic(dic: Dictionary) -> WeaponStatistics:
	var weapon_statistics: WeaponStatistics = WeaponStatistics.new()

	for key: String in dic.keys():
		if weapon_statistics.get(key) != null:
			weapon_statistics.set(key, dic[key])
		else:
			printerr("Data: Invalid property: " + key)

	return weapon_statistics

func to_dic() -> Dictionary:
	var dic: Dictionary = {}

	dic["enemies_killed"] = enemies_killed
	dic["times_picked_up"] = times_picked_up

	return dic
