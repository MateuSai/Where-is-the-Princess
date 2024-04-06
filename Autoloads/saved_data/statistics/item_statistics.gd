class_name ItemStatistics

var times_picked_up: int = 0


static func from_dic(dic: Dictionary) -> ItemStatistics:
	var item_statistics: ItemStatistics = ItemStatistics.new()

	for key: String in dic.keys():
		if item_statistics.get(key) != null:
			item_statistics.set(key, dic[key])
		else:
			printerr("Data: Invalid property: " + key)

	return item_statistics

func to_dic() -> Dictionary:
	var dic: Dictionary = {}

	dic["times_picked_up"] = times_picked_up

	return dic
