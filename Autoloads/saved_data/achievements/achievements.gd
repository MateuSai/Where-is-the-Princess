class_name Achievements

const SAVE_PATH: String = "user://achievements.json"

enum Achievement {
	defeat_boden,
	defeat_necro_tromp,

	drown,

	rescue_all_animals,
}

var achievements: Dictionary = {
	achievent_int_to_string(Achievement.defeat_boden): false,
	achievent_int_to_string(Achievement.defeat_necro_tromp): false,

	achievent_int_to_string(Achievement.drown): false,

	achievent_int_to_string(Achievement.rescue_all_animals): {
		current = 0,
		goal = Data.AnimalsToRescue.size()
	},
}

#func _init() -> void:
#	for achievement_id: String in Achievement.keys():
#		achievements[achievement_id] = false

func achievent_int_to_string(achievement: Achievement) -> String:
	Log.err_cond_false(Achievement.values().has(achievement), "Invalid achievement id!")
	return Achievement.keys()[achievement]

static func new_with_achievements(achievements_dic: Dictionary) -> Achievements:
	var achiev: Achievements = Achievements.new()
	achiev.achievements.merge(achievements_dic, true)
	return achiev

static func load_from_file() -> Achievements:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		Log.info("achievements file does not exist yet, using default values...")
		return Achievements.new()
	var parse_res: Variant = JSON.parse_string(file.get_as_text())
	Log.err_cond_null(parse_res, "Could not parse achievements json!")
	return new_with_achievements(parse_res)

func save() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	Log.err_cond_null(file, "Could not open achievements json save path for write!")
	file.store_string(JSON.stringify(achievements, "\t"))

func complete_achievement(achievement: Achievement) -> void:
	var achievement_id: String = achievent_int_to_string(achievement)

	achievements[achievement_id] = true
	Log.info("Achievement " + achievement_id + " completed!")
	save()

func add_progress_to_achievement(achievement: Achievement, amount: int) -> void:
	var achievement_id: String = achievent_int_to_string(achievement)

	achievements[achievement_id].current += amount
	#if achievements[achievement_id].current >= achievements[achievement_id].goal:
	#	complete_achievement(achievement)

	save()