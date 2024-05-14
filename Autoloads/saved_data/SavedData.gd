extends Node

const BIOMES_FOLDER_PATH: String = "res://Rooms/Biomes/"

const USER_FOLDER: String = "user://"

const RUN_STATS_SAVE_NAME: String = "run_stats.res"

var data: Data
signal data_loaded()
var statistics: Statistics

var mod_room_paths: Dictionary = {}

var mod_weapon_paths: PackedStringArray = []

var mod_armor_paths: PackedStringArray = []
#var discovered_mod_armor_paths: PackedStringArray = []

var mod_permanent_item_paths: PackedStringArray = []
var mod_temporal_item_paths: PackedStringArray = []

var run_stats: RunStats:
	set(new_run_stats):
		if run_stats:
			run_stats._on_free()
		run_stats = new_run_stats
		DebugInfo.start_time = Time.get_ticks_msec()

#var mods: Array[Mod] = []

var biome_conf: BiomeConf

signal dark_souls_changed(new_value: int)

var last_time_killed_by: String = ""

func _ready() -> void:
	print_rich("\n[b]--- SavedData ---[/b]")
	# save_data()
	data = Data._load()
	data_loaded.emit()
	statistics = Statistics._load()
	#print(data)

	_load_run_stats()

	change_biome_by_id_or_path(run_stats.biome, run_stats.level)
	# print(biome_conf)

	var user_dir: DirAccess = DirAccess.open(USER_FOLDER)
	assert(user_dir) # Siempre deberiamos poder abrir el directorio del usuario

	print("")

	if OS.has_feature("editor"):
		_print_info_that_may_be_useful()

	print("")

func save_run_stats() -> void:
	ResourceSaver.save(run_stats, USER_FOLDER.path_join(RUN_STATS_SAVE_NAME))

func _load_run_stats() -> void:
	if FileAccess.file_exists(USER_FOLDER.path_join(RUN_STATS_SAVE_NAME)):
		#run_stats = load(USER_FOLDER.path_join(RUN_STATS_SAVE_NAME))
		run_stats = ResourceLoader.load(USER_FOLDER.path_join(RUN_STATS_SAVE_NAME), "", ResourceLoader.CACHE_MODE_IGNORE) as RunStats
	else:
		run_stats = RunStats.new()

func _remove_and_reset_run_stats() -> void:
	DirAccess.remove_absolute(USER_FOLDER.path_join(RUN_STATS_SAVE_NAME))
	run_stats = RunStats.new()
	change_biome_by_id_or_path(run_stats.biome, run_stats.level)

func are_there_run_stats() -> bool:
	return FileAccess.file_exists(USER_FOLDER.path_join(RUN_STATS_SAVE_NAME))

func reset_run_stats() -> void:
	run_stats = RunStats.new()

func set_dark_souls(new_value: int) -> void:
	data.dark_souls = new_value
	dark_souls_changed.emit(data.dark_souls)

func add_enemy_times_killed(enemy_id: StringName) -> void:
	statistics.add_enemy_times_killed(enemy_id)

	var enemy_unlock_weapon_on_kills: UnlockWeaponOnKills = Globals.get_enemy_unlock_weapon_on_kills(enemy_id)
	if enemy_unlock_weapon_on_kills and statistics.get_enemy_statistics(enemy_id).times_killed == enemy_unlock_weapon_on_kills.kills_necessary:
		add_extra_available_weapon(enemy_unlock_weapon_on_kills.weapon_path)
		(get_tree().current_scene as Game).show_notification(
			load("res://ui/notifications/weapon_unlocked_notification.tscn"),
			{
				id=Weapon.get_id_from_path(enemy_unlock_weapon_on_kills.weapon_path),
				data=Weapon.get_data(Weapon.get_id_from_path(enemy_unlock_weapon_on_kills.weapon_path))
			}
		)

func add_enemy_player_kill(enemy_id: String) -> void:
	statistics.add_enemy_player_kill(enemy_id)

func get_biome_conf() -> BiomeConf:
	return biome_conf

func get_current_level_spawn_shape() -> Rooms.SpawnShape:
	if biome_conf.levels.size() >= SavedData.run_stats.level:
		match biome_conf.levels[SavedData.run_stats.level - 1].spawn_shape_type.to_lower():
			"circle":
				var radius: float = biome_conf.levels[SavedData.run_stats.level - 1].spawn_shape_radius
				return Rooms.CircleSpawnShape.new(radius)
			"rectangle":
				return Rooms.RectangleSpawnShape.new(Vector2(biome_conf.levels[SavedData.run_stats.level - 1].spawn_shape_width, biome_conf.levels[SavedData.run_stats.level - 1].spawn_shape_height))

	return Rooms.CircleSpawnShape.new(100)

func get_vertical_corridor_symmetric_lights() -> bool:
	if biome_conf.vertical_corridor_symmetric_lights:
		return biome_conf.vertical_corridor_symmetric_lights
	else:
		return false

func get_disable_horizontal_separation_steering() -> bool:
	if biome_conf.levels.size() >= SavedData.run_stats.level and biome_conf.levels[SavedData.run_stats.level - 1].disable_horizontal_separation_steering:
		return biome_conf.levels[SavedData.run_stats.level - 1].disable_horizontal_separation_steering
	return false

func get_num_rooms(type: String) -> int:
	if biome_conf.levels.size() >= SavedData.run_stats.level:
		return biome_conf.levels[SavedData.run_stats.level - 1].get("num_" + type + "_rooms")
	else:
		return biome_conf.get("default_num_" + type + "_rooms")

## This function assumes all the paths you put on the overwrite conf array are correct. If you you put some room names that don't exist, the game will crash. Returns [""] if the paths are not being overwritten
func get_overwrite_room_paths(type: String) -> PackedStringArray:
	if biome_conf.levels.size() >= run_stats.level:
		if type.begins_with("end"):
			var splitted_type: PackedStringArray = type.split("_")
			return biome_conf.levels[run_stats.level - 1].get_overwrite_end_rooms(splitted_type[1])
		elif biome_conf.levels[run_stats.level - 1].get("overwrite_" + type + "_rooms") != null:
			return biome_conf.levels[run_stats.level - 1].get("overwrite_" + type + "_rooms")
		#print(room_paths)
#		room_paths = room_paths.map(func(room_name: String) -> String:
#			return room_name + ".tscn"
#		)
		#print(room_paths)

	return [""]

func get_level_exit_names() -> Array:
	if biome_conf.levels.size() >= run_stats.level:
		return biome_conf.levels[run_stats.level - 1].get_exit_names()
	else:
		return []

func get_overwrite_connections() -> Array[Array]:
	var connections: Array = []

	if biome_conf.levels.size() >= run_stats.level and not biome_conf.levels[run_stats.level - 1].overwrite_connections.is_empty():
		connections = biome_conf.levels[run_stats.level - 1].overwrite_connections

	var ret: Array[Array] = []
	ret.assign(connections)
	return ret

func get_ignored_rooms() -> PackedStringArray:
	return data.ignored_rooms

func add_ignored_room(room_path: String) -> void:
	data.ignored_rooms.push_back(room_path)
	data.save()

## You can specify a vanilla biome like [code]"forest"[/code] or [code]"sewer"[/code] or you can use an absolute path to the config.json for your own biome
func change_biome_by_id_or_path(new_biome: String, level: int=1) -> void:
	biome_conf = get_biome_by_id_or_path(new_biome)
	assert(biome_conf)

	run_stats.biome = new_biome
	run_stats.level = level

	SavedData.statistics.add_biome_times_entered(biome_conf.name)

func get_biome_json_string_by_id_or_path(biome: String) -> String:
	if not biome.is_absolute_path():
		biome = BIOMES_FOLDER_PATH + biome + "/conf.json"

	var biome_json_string: String = ""

	var file: FileAccess = FileAccess.open(biome, FileAccess.READ)
	if file:
		biome_json_string = file.get_as_text()
	else:
		push_error("There is not file at " + biome)

	return biome_json_string

func get_biome_by_id_or_path(biome: String) -> BiomeConf:
	var ret_biome_conf: BiomeConf = null

	var biome_json_string: String = get_biome_json_string_by_id_or_path(biome)
	if not biome_json_string.is_empty():
		var json: JSON = JSON.new()
		if json.parse(biome_json_string):
			push_error("Error reading " + biome + "! Loading default biome conf...")
		else:
			if json.data is Dictionary:
				ret_biome_conf = BiomeConf.from_dic(json.data as Dictionary)
			else:
				push_error("Could not load file biome data as json, using default values...")
	else:
		Log.err("json string is empty")

	return ret_biome_conf

func _change_biome_by_conf(conf: BiomeConf, level: int=1) -> void:
	self.biome_conf = conf
	run_stats.biome = "Biome loaded with config, can't be saved to run stats"
	run_stats.level = level

## room_type must be "combat", "end", "special" or "start"
## [br][br]
## You only have to specify end_to if the room_type is "end". This parameter indicates the biome you will go to when you enter the exit on the end room
func add_volatile_room(mod_id: String, room_path: String, biome: String, room_type: String, end_to: String="") -> void:
	biome = biome.to_lower()
	room_type = room_type.to_lower()
	end_to = end_to.to_lower()

	if not mod_room_paths.has(biome):
		mod_room_paths[biome] = {}
	if not mod_room_paths[biome].has(room_type):
		@warning_ignore("incompatible_ternary")
		mod_room_paths[biome][room_type] = ({} if room_type == "end" else [])

	if room_type == "end" and not end_to.is_empty():
		if not mod_room_paths[biome][room_type].has(end_to):
			mod_room_paths[biome][room_type][end_to] = []
		mod_room_paths[biome][room_type][end_to].push_back(room_path)
	else:
		mod_room_paths[biome][room_type].push_back(room_path)

	ModLoaderLog.success(room_path + " with biome " + biome + " and type " + room_type + " added succesfully", mod_id)

func get_mod_room_paths(biome: String, room_type: String, end_to: String="") -> PackedStringArray:
	biome = biome.to_lower()
	room_type = room_type.to_lower()
	end_to = end_to.to_lower()

	if mod_room_paths.has(biome) and mod_room_paths[biome].has(room_type) and room_type != "end":
		var a: Array = mod_room_paths[biome][room_type]
		return PackedStringArray(a)
	elif mod_room_paths.has(biome) and mod_room_paths[biome].has(room_type) and mod_room_paths[biome][room_type].has(end_to):
		var a: Array = mod_room_paths[biome][room_type][end_to]
		return PackedStringArray(a)
	else:
		return PackedStringArray([])

func add_mod_weapon(weapon_path: String) -> void:
	if mod_weapon_paths.has(weapon_path):
		return

	mod_weapon_paths.push_back(weapon_path)

func add_extra_available_weapon(weapon_path: String) -> void:
	data.add_extra_available_weapon(weapon_path)

func get_available_weapon_paths() -> PackedStringArray:
	var weapon_paths: Array = data.get_available_weapons().duplicate()
	#armor_paths.append_array(mod_armor_paths)
	return PackedStringArray(weapon_paths)

## Vanilla and mod. Available and not available. All the weapons in the game
func get_all_weapon_paths() -> PackedStringArray:
	var ret: PackedStringArray = data.ALL_VANILLA_WEAPONS.duplicate()
	ret.append_array(mod_weapon_paths)
	return ret

func get_discovered_weapon_paths() -> PackedStringArray:
	return data.get_discovered_weapons()

func discover_weapon_if_not_already(weapon_path: String) -> void:
	data.discover_weapon_if_not_already(weapon_path)

func get_random_available_weapon_path() -> String:
	var available_weapons: PackedStringArray = get_available_weapon_paths()

	return available_weapons[randi() % available_weapons.size()]

func add_extra_available_armor(armor_path: String) -> void:
	data.add_extra_available_armor(armor_path)

func get_random_available_armor_path(quality: Item.Quality) -> String:
	var possible_results: Array[String] = []

	for armor_path: String in get_available_armor_paths():
		if load(armor_path).new().get_quality() == quality:
			possible_results.push_back(armor_path)

	assert(not possible_results.is_empty())
	possible_results.shuffle()
	return possible_results[0]

func get_discovered_armors_paths() -> PackedStringArray:
	var ret: PackedStringArray = []
	ret.append_array(data.get_discovered_armors().duplicate())
	return ret

## Vanilla and mod. Available and not available. All the armors in the game
func get_all_armor_paths() -> PackedStringArray:
	var ret: PackedStringArray = []
	ret.append_array(data.ALL_VANILLA_ARMORS.duplicate())
	ret.append_array(mod_armor_paths)
	return ret

## Adds an armor only for this session. Use this for mods to load the armor each time the mod loads. The new armors will appear at the wardrobe on the basecamp and it may appear inside the game on the events where a random armor is choosen (like the shop)
func add_mod_armor(armor_path: String) -> void:
	if mod_armor_paths.has(armor_path):
		return

	mod_armor_paths.push_back(armor_path)

func discover_armor_if_not_already(armor_path: String) -> void:
	data.discover_armor_if_not_already(armor_path)

func discover_mod_armor(armor_path: String) -> void:
	if not mod_armor_paths.has(armor_path):
		printerr("You must add the armor first with SavedData.add_mod_armor(armor_path)")
		return
	elif data._discovered_armors.has(armor_path):
		print("Armor " + armor_path + " already discovered")
		return

	discover_armor_if_not_already(armor_path)

func get_available_armor_paths() -> PackedStringArray:
	var armor_paths: Array = data.get_available_armors().duplicate()
	#armor_paths.append_array(discovered_mod_armor_paths)
	return PackedStringArray(armor_paths)

func get_all_items_paths() -> PackedStringArray:
	var ret: PackedStringArray = data.ALL_VANILLA_PERMANENT_ITEMS.duplicate()
	ret.append_array(data.ALL_VANILLA_TEMPORAL_ITEMS)
	ret.append_array(mod_permanent_item_paths)
	ret.append_array(mod_temporal_item_paths)
	return ret

func get_discovered_all_items_paths() -> PackedStringArray:
	var ret: PackedStringArray = data.get_discovered_permanent_items()
	ret.append_array(data.get_discovered_temporal_items())
	return ret

func add_extra_available_temporal_item(item_path: String) -> void:
	data.add_extra_available_temporal_item(item_path)

## Adds a temporal item only for this session. Use this for mods to load the item each time the mod loads.
func add_mod_temporal_item(item_path: String) -> void:
	if mod_temporal_item_paths.has(item_path):
		return

	mod_temporal_item_paths.push_back(item_path)

func discover_temporal_item_if_not_already(item_path: String) -> void:
	data.discover_temporal_item_if_not_already(item_path)

func get_available_temporal_item_paths() -> PackedStringArray:
	var temporal_item_paths: Array = data.get_available_temporal_items().duplicate()
	temporal_item_paths.append_array(mod_temporal_item_paths)
	return PackedStringArray(temporal_item_paths)

func add_extra_available_permanent_item(item_path: String) -> void:
	data.add_extra_available_permanent_item(item_path)

## Adds a permanent item only for this session. Use this for mods to load the item each time the mod loads.
func add_mod_permanent_item(item_path: String) -> void:
	if mod_permanent_item_paths.has(item_path):
		return

	mod_permanent_item_paths.push_back(item_path)

func discover_permanent_item_if_not_already(item_path: String) -> void:
	data.discover_permanent_item_if_not_already(item_path)

func get_available_permanent_item_paths() -> PackedStringArray:
	var permanent_item_paths: Array = data.get_available_permanent_items().duplicate()
	permanent_item_paths.append_array(mod_permanent_item_paths)
	return PackedStringArray(permanent_item_paths)

func get_available_player_upgrades_paths() -> PackedStringArray:
	return data.get_available_player_upgrades()

func get_random_available_item_path(quality: Item.Quality=Item.Quality.COMMON) -> String:
	var possible_results: Array[String] = []

	for item_path_array: PackedStringArray in [get_available_temporal_item_paths(), get_available_permanent_item_paths()]:
		for item_path: String in item_path_array:
			if run_stats.get_permanent_passive_items_ids().has((load(item_path).new() as PassiveItem).get_id()):
				continue
			if load(item_path).new().get_quality() == quality:
				possible_results.push_back(item_path)

	assert(not possible_results.is_empty())
	possible_results.shuffle()
	return possible_results[0]

func get_limit_entrance_connections_to_one() -> bool:
	if biome_conf.levels.size() >= run_stats.level:
		return biome_conf.levels[run_stats.level - 1].limit_entrance_connections_to_one
	else:
		return false

func add_completed_dialogue(dialogue: String) -> void:
	data.add_completed_dialogue(dialogue)

func add_player_times_killed(killed_by: String) -> void:
	last_time_killed_by = killed_by
	statistics.add_player_times_killed()

func _print_info_that_may_be_useful() -> void:
	var data_dic: Dictionary = {
		"Armors": [Data.ALL_VANILLA_ARMORS, Data.AVAILABLE_ARMORS_FROM_START],
		"Weapons": [Data.ALL_VANILLA_WEAPONS, Data.AVAILABLE_WEAPONS_FROM_START],
		"Permanent items": [Data.ALL_VANILLA_PERMANENT_ITEMS, Data.AVAILABLE_PERMANENT_ITEMS_FROM_START],
		"Temporal items": [Data.ALL_VANILLA_TEMPORAL_ITEMS, Data.AVAILABLE_TEMPORAL_ITEMS_FROM_START],
	}
	for key: String in data_dic.keys():
		Log.info(key + ":")
		Log.info("\tAll vanilla: " + str(Globals.array_of_paths_to_filenames(Array(data_dic[key][0]))))
		Log.info("\tAvailable from start: " + str(Globals.array_of_paths_to_filenames(Array(data_dic[key][1]))))
		Log.info("\tNot available from start: " + str(Globals.array_of_paths_to_filenames(
			Globals.get_missing_elements(
				Array(data_dic[key][0]),
				Array(data_dic[key][1])
			)
		)))

	var permanent_items_without_cursed_counterpart: Array[String] = []
	for item_path: String in Data.ALL_VANILLA_PERMANENT_ITEMS:
		var item: PermanentPassiveItem = load(item_path).new()
		if item.get_cursed_version_path().is_empty():
			permanent_items_without_cursed_counterpart.push_back(item.get_id())
	Log.info("Permanent items without cursed counterpart: " + str(permanent_items_without_cursed_counterpart))
