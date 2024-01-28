class_name EnemyData

var kills: int = 0


static func from_dic(dic: Dictionary) -> Data:
	var data: Data = Data.new()

	for key: String in dic.keys():
		if data.get(key) != null:
			data.set(key, dic[key])
		else:
			printerr("Data: Invalid property: " + key)

	return data

func to_dic() -> Dictionary:
	var dic: Dictionary = {}

	dic["kills"] = kills

	return dic
