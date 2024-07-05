class_name Achievements

const SAVE_PATH: String = "user://achievements.json"

const ICONS: Array[Array] = [
	[ preload ("res://Art/achievements/logro_trump_0.jpg"), preload ("res://Art/achievements/logro_trump_1.jpg")],
	[ preload ("res://Art/achievements/logro_trump_0.jpg"), preload ("res://Art/achievements/logro_trump_1.jpg")],

	[ preload ("res://Art/achievements/logro_trump_0.jpg"), preload ("res://Art/achievements/logro_trump_1.jpg")],
	[ preload ("res://Art/achievements/logro_trump_0.jpg"), preload ("res://Art/achievements/logro_trump_1.jpg")],

	[ preload ("res://Art/achievements/logro_trump_0.jpg"), preload ("res://Art/achievements/logro_trump_1.jpg")],
]

enum Achievement {
	forest_druid,
	sewer_necromancer,

	drown,
	crocodile_help,

	pet_kidnapper,
}

var achievements: Dictionary = {
	achievement_int_to_string(Achievement.forest_druid): {
		completed = false
	},
	achievement_int_to_string(Achievement.sewer_necromancer): {
		completed = false
	},

	achievement_int_to_string(Achievement.drown): {
		completed = false
	},
	achievement_int_to_string(Achievement.crocodile_help): {
		completed = false
	},

	achievement_int_to_string(Achievement.pet_kidnapper): {
		completed = false,
		current = 0,
		goal = Data.AnimalsToRescue.size()
	},
}

#func _init() -> void:
#	for achievement_id: String in Achievement.keys():
#		achievements[achievement_id] = false

func achievement_int_to_string(achievement: Achievement) -> String:
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

func is_achievement_completed(achievement: Achievement) -> bool:
	return achievements[achievement_int_to_string(achievement)].completed

func complete_achievement(achievement: Achievement) -> void:
	var achievement_id: String = achievement_int_to_string(achievement)

	achievements[achievement_id].completed = true
	Log.info("Achievement " + achievement_id + " completed!")
	save()

	if Globals.is_steam_enabled():
		Steam.setAchievement(achievement_id)
		Steam.storeStats()

func add_progress_to_achievement(achievement: Achievement, amount: int) -> void:
	var achievement_id: String = achievement_int_to_string(achievement)

	achievements[achievement_id].current += amount
	if achievements[achievement_id].current >= achievements[achievement_id].goal:
		complete_achievement(achievement)

	save()

func get_not_achieved_icon(achievement: Achievement) -> Texture2D:
	return ICONS[achievement][0]

func get_achieved_icon(achievement: Achievement) -> Texture2D:
	return ICONS[achievement][1]