class_name Achievements

const SAVE_PATH: String = "user://achievements.json"

enum Achievement {
	defeat_boden,
	defeat_necro_tromp,

	drown,
	eaten_by_crocodile,
	use_a_crocodile_to_kill_an_enemy,

	rescue_all_animals,
}

var achievements: Dictionary = {
	achievent_int_to_string(Achievement.defeat_boden): {
		completed = false
	},
	achievent_int_to_string(Achievement.defeat_necro_tromp): {
		completed = false
	},

	achievent_int_to_string(Achievement.drown): {
		completed = false
	},
	achievent_int_to_string(Achievement.eaten_by_crocodile): {
		completed = false
	},
	achievent_int_to_string(Achievement.use_a_crocodile_to_kill_an_enemy): {
		completed = false
	},

	achievent_int_to_string(Achievement.rescue_all_animals): {
		completed = false,
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

	if Globals.is_steam_enabled():
		achiev._complete_steam_achievements_completed_on_file_but_not_on_steam()

	return achiev

static func load_from_file() -> Achievements:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		Log.info("achievements file does not exist yet, using default values...")
		return Achievements.new()
	var parse_res: Variant = JSON.parse_string(file.get_as_text())
	Log.err_cond_null(parse_res, "Could not parse achievements json!")
	return new_with_achievements(parse_res)

func _complete_steam_achievements_completed_on_file_but_not_on_steam() -> void:
	Log.debug("Checking if achievement is saved on file, but not on steam...")

	var some_achievement_achieved: bool = false

	for id: String in achievements.keys():
		Log.debug("Checking " + id + "...")

		var steam_achievement: Dictionary = Steam.getAchievement(id)

		if not steam_achievement.ret:
			Log.warn(id + " on save file but does not exist on steam")
			continue

		if achievements[id].completed and not steam_achievement.achieved:
			Log.debug("Setting achievement " + id + " on steam...")
			Steam.setAchievement(id)
			some_achievement_achieved = true

	if some_achievement_achieved:
		Steam.storeStats()

func save() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	Log.err_cond_null(file, "Could not open achievements json save path for write!")
	file.store_string(JSON.stringify(achievements, "\t"))

func is_achievement_completed(achievement_id: String) -> bool:
	return achievements[achievement_id].completed

func complete_achievement(achievement: Achievement) -> void:
	var achievement_id: String = achievent_int_to_string(achievement)

	achievements[achievement_id].completed = true
	Log.info("Achievement " + achievement_id + " completed!")
	save()

	if Globals.is_steam_enabled():
		Steam.setAchievement(achievement_id)
		Steam.storeStats()

func add_progress_to_achievement(achievement: Achievement, amount: int) -> void:
	var achievement_id: String = achievent_int_to_string(achievement)

	achievements[achievement_id].current += amount
	if achievements[achievement_id].current >= achievements[achievement_id].goal:
		complete_achievement(achievement)

	save()