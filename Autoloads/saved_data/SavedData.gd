extends Node

const BIOMES_FOLDER_PATH: String = "res://Rooms/Biomes/"

const USER_FOLDER: String = "user://"
#const MODS_FOLDER_NAME: String = "mods/"
#const MODS_CONF_FILE_NAME: String = "mods_conf.json"
const DATA_SAVE_NAME: String = "data.json"

const RUN_STATS_SAVE_NAME: String = "run_stats.res"

var data: Data

var volatile_room_paths: Dictionary = {}

var volatile_armor_paths: Array[String] = []

var volatile_permanent_item_paths: Array[String] = []
var volatile_temporal_item_paths: Array[String] = []

var run_stats: RunStats

#var mods: Array[Mod] = []

var biome_conf: BiomeConf

signal dark_souls_changed(new_value: int)


func _ready() -> void:
	print("--- SavedData ---")
	# save_data()
	_load_data()
	#print(data)

	_load_run_stats()

	_change_biome_conf(run_stats.biome)
	# print(biome_conf)

	var user_dir: DirAccess = DirAccess.open(USER_FOLDER)
	assert(user_dir) # Siempre deberiamos poder abrir el directorio del usuario

#	if not user_dir.dir_exists(MODS_FOLDER_NAME):
#		print("Can't find mods folder, creating it...")
#		if user_dir.make_dir(MODS_FOLDER_NAME):
#			printerr("Error creating mods directory!!")
#			return
#
#	var mods_dir: DirAccess = DirAccess.open(USER_FOLDER + MODS_FOLDER_NAME)
#	if mods_dir == null:
#		printerr("Error opening mods directory!")
#		return
#
#	var mods_conf: Dictionary = _load_mods_conf()
#	for file_name in mods_dir.get_files():
#		print(file_name)
#		if mods_conf.has(file_name):
#			mods.push_back(Mod.from_dictionary(mods_conf[file_name]))
#		else:
#			mods.push_back(Mod.new(USER_FOLDER + MODS_FOLDER_NAME + file_name))
#			if not ProjectSettings.load_resource_pack(USER_FOLDER + MODS_FOLDER_NAME + file_name):
#				printerr("Error loading " + USER_FOLDER + MODS_FOLDER_NAME + file_name + " mod!")
		#var room: PackedScene = load(USER_FOLDER + ROOMS_FOLDER_NAME + file_name)
		#custom_rooms.push_back(room)
		#room_paths.push_back(USER_FOLDER + ROOMS_FOLDER_NAME + file_name)

	print("\t")


func save_data() -> void:
	var file: FileAccess = FileAccess.open(USER_FOLDER + DATA_SAVE_NAME, FileAccess.WRITE)
	if not file:
		printerr("Error opening " + USER_FOLDER + DATA_SAVE_NAME + " for writing!! I can't save your data, bro")
		return
	file.store_string(JSON.stringify(data.to_dic(), "\t"))
	file.close()
	#print(JSON.new().stringify(data, "\t"))


func _load_data() -> void:
	var file: FileAccess = FileAccess.open(USER_FOLDER + DATA_SAVE_NAME, FileAccess.READ)
	if file:
		print("Save data found. Loading it...")
		var json: JSON = JSON.new()
		json.parse(file.get_as_text())
		if json.data is Dictionary:
			data = Data.from_dic(json.data as Dictionary)
		else:
			printerr("Could not load file data as json, using default values...")
			data = Data.new()
	else:
		print("No save data found, using default value...")
		data = Data.new()


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


func are_there_run_stats() -> bool:
	return FileAccess.file_exists(USER_FOLDER.path_join(RUN_STATS_SAVE_NAME))


#func save_mods_conf() -> void:
#	var mods_dic: Dictionary = {}
#	for mod in mods:
#		mods_dic[mod.get_name()] = mod.to_dictionary()
#
#	var file: FileAccess = FileAccess.open(USER_FOLDER + MODS_CONF_FILE_NAME, FileAccess.WRITE)
#	if not file:
#		printerr("Error opening " + USER_FOLDER + MODS_CONF_FILE_NAME + " for writing!! I can't save your mods configuration, bro")
#		return
#	file.store_string(JSON.stringify(mods_dic, "\t"))
#	file.close()
#
#
#func _load_mods_conf() -> Dictionary:
#	var file: FileAccess = FileAccess.open(USER_FOLDER + MODS_CONF_FILE_NAME, FileAccess.READ)
#	if file:
#		print("Mods configuration found. Loading it...")
#		var json: JSON = JSON.new()
#		json.parse(file.get_as_text())
#		return json.data
#
#	return {}
#
#
#func load_mods() -> void:
#	if OS.has_feature("editor"):
#		print("Not loading mods because they are only supported on the exported version")
#		return
#
#	for mod in mods:
#		if not ProjectSettings.load_resource_pack(mod.resource_path):
#			printerr("Error loading " + mod.resource_path + " mod!")


func reset_run_stats() -> void:
	run_stats = RunStats.new()


func set_dark_souls(new_value: int) -> void:
	data.dark_souls = new_value
	dark_souls_changed.emit(data.dark_souls)


func add_kill(enemy_id: StringName) -> void:
	if not data.kills.has(enemy_id):
		data.kills[enemy_id] = 0

	data.kills[enemy_id] += 1

	var enemy_unlock_weapon_on_kills: UnlockWeaponOnKills = Globals.get_enemy_unlock_weapon_on_kills(enemy_id)
	if enemy_unlock_weapon_on_kills and data.kills[enemy_id] == enemy_unlock_weapon_on_kills.kills_necessary:
		discover_weapon(enemy_unlock_weapon_on_kills.weapon_path)

	save_data()


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
	if biome_conf.levels.size() >= run_stats.level and biome_conf.levels[run_stats.level - 1].get("overwrite_" + type + "_rooms") != null:
		return biome_conf.levels[run_stats.level - 1].get("overwrite_" + type + "_rooms")
		#print(room_paths)
#		room_paths = room_paths.map(func(room_name: String) -> String:
#			return room_name + ".tscn"
#		)
		#print(room_paths)
	else:
		return [""]


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
	save_data()


func change_biome(new_biome: String) -> void:
	_change_biome_conf(new_biome)
	run_stats.biome = new_biome
	run_stats.level = 1


func _change_biome_conf(biome: String) -> void:
	var json: JSON = JSON.new()
	if json.parse(FileAccess.open(BIOMES_FOLDER_PATH + biome + "/conf.json", FileAccess.READ).get_as_text()):
		printerr("Error reading " + BIOMES_FOLDER_PATH + biome + "/conf.json" + "! Loading default biome conf...")
		biome_conf = BiomeConf.new()
	else:
		if json.data is Dictionary:
			biome_conf = BiomeConf.from_dic(json.data as Dictionary)
		else:
			printerr("Could not load file biome data as json, using default values...")
			biome_conf = BiomeConf.new()


## room_type must be "combat", "end", "special" or "start"
## [br][br]
## You only have to specify end_to if the room_type is "end". This parameter indicates the biome you will go to when you enter the exit on the end room
func add_volatile_room(room_path: String, biome: String, room_type: String, end_to: String = "") -> void:
	biome = biome.to_lower()
	room_type = room_type.to_lower()
	end_to = end_to.to_lower()

	if not volatile_room_paths.has(biome):
		volatile_room_paths[biome] = {}
	if not volatile_room_paths[biome].has(room_type):
		@warning_ignore("incompatible_ternary")
		volatile_room_paths[biome][room_type] = ({} if room_type == "end" else [])

	if room_type == "end" and not end_to.is_empty():
		if not volatile_room_paths[biome][room_type].has(end_to):
			volatile_room_paths[biome][room_type][end_to] = []
		volatile_room_paths[biome][room_type][end_to].push_back(room_path)
	else:
		volatile_room_paths[biome][room_type].push_back(room_path)


func get_volatile_room_paths(biome: String, room_type: String, end_to: String = "") -> PackedStringArray:
	biome = biome.to_lower()
	room_type = room_type.to_lower()
	end_to = end_to.to_lower()

	if volatile_room_paths.has(biome) and volatile_room_paths[biome].has(room_type) and room_type != "end":
		return PackedStringArray(volatile_room_paths[biome][room_type])
	elif volatile_room_paths.has(biome) and volatile_room_paths[biome].has(room_type) and volatile_room_paths[biome][room_type].has(end_to):
		return PackedStringArray(volatile_room_paths[biome][room_type][end_to])
	else:
		return PackedStringArray([])


func discover_weapon(weapon_path: String) -> void:
	if not data.discovered_weapons.has(weapon_path):
		data.discovered_weapons.push_back(weapon_path)
#	if data.undiscovered_weapons.has(weapon_path):
#		data.undiscovered_weapons.remove_at(data.undiscovered_weapons.find(weapon_path))

	save_data()


func get_discovered_weapon_paths() -> PackedStringArray:
	var weapon_paths: Array = data.discovered_weapons.duplicate()
	#armor_paths.append_array(volatile_armor_paths)
	return PackedStringArray(weapon_paths)


#func get_undiscovered_weapon_paths() -> PackedStringArray:
#	var weapon_paths: Array = data.undiscovered_weapons.duplicate()
#	#armor_paths.append_array(volatile_armor_paths)
#	return PackedStringArray(weapon_paths)


func get_random_discovered_weapon_path() -> String:
	var discovered_weapons: PackedStringArray = get_discovered_weapon_paths()

	return discovered_weapons[randi() % discovered_weapons.size()]


func discover_armor(armor_path: String) -> void:
	if not data.discovered_armors.has(armor_path):
		data.discovered_armors.push_back(armor_path)
		save_data()


func get_random_discovered_armor_path() -> String:
	var armor_paths: PackedStringArray = get_armor_paths()
	return armor_paths[randi() % armor_paths.size()]


## Adds an armor only for this session. Use this for mods to load the armor each time the mod loads. The new armors will appear at the wardrobe on the basecamp and it may appear inside the game on the events where a random armor is choosen (like the shop)
func add_volatile_armor(armor_path: String) -> void:
	if volatile_armor_paths.has(armor_path):
		return

	volatile_armor_paths.push_back(armor_path)


func get_armor_paths() -> PackedStringArray:
	var armor_paths: Array = data.discovered_armors.duplicate()
	armor_paths.append_array(volatile_armor_paths)
	return PackedStringArray(armor_paths)


func discover_temporal_item(item_path: String) -> void:
	if not data.discovered_temporal_items.has(item_path):
		data.discovered_temporal_items.push_back(item_path)
#	if data.undiscovered_temporal_items.has(item_path):
#		data.undiscovered_temporal_items.remove_at(data.undiscovered_temporal_items.find(item_path))

	save_data()


## Adds a temporal item only for this session. Use this for mods to load the item each time the mod loads.
func add_volatile_temporal_item(item_path: String) -> void:
	if volatile_temporal_item_paths.has(item_path):
		return

	volatile_temporal_item_paths.push_back(item_path)


func get_discovered_temporal_item_paths() -> PackedStringArray:
	var temporal_item_paths: Array = data.discovered_temporal_items.duplicate()
	temporal_item_paths.append_array(volatile_temporal_item_paths)
	return PackedStringArray(temporal_item_paths)


#func get_undiscovered_temporal_item_paths() -> PackedStringArray:
#	var temporal_item_paths: Array = data.undiscovered_temporal_items.duplicate()
#	#temporal_item_paths.append_array(volatile_temporal_item_paths)
#	return PackedStringArray(temporal_item_paths)


func discover_permanent_item(item_path: String) -> void:
	if not data.discovered_permanent_items.has(item_path):
		data.discovered_permanent_items.push_back(item_path)
#	if data.undiscovered_permanent_items.has(item_path):
#		data.undiscovered_permanent_items.remove_at(data.undiscovered_permanent_items.find(item_path))

	save_data()


## Adds a permanent item only for this session. Use this for mods to load the item each time the mod loads.
func add_volatile_permanent_item(item_path: String) -> void:
	if volatile_permanent_item_paths.has(item_path):
		return

	volatile_permanent_item_paths.push_back(item_path)


func get_discovered_permanent_item_paths() -> PackedStringArray:
	var permanent_item_paths: Array = data.discovered_permanent_items.duplicate()
	permanent_item_paths.append_array(volatile_permanent_item_paths)
	return PackedStringArray(permanent_item_paths)


#func get_undiscovered_permanent_item_paths() -> PackedStringArray:
#	var permanent_item_paths: Array = data.undiscovered_permanent_items.duplicate()
#	#permanent_item_paths.append_array(volatile_permanent_item_paths)
#	return PackedStringArray(permanent_item_paths)


func get_random_discovered_item_path(quality: Item.Quality = Item.Quality.COMMON) -> String:
	var possible_results: Array[String] = []

	for item_path_array: PackedStringArray in [get_discovered_temporal_item_paths(), get_discovered_permanent_item_paths()]:
		for item_path: String in item_path_array:
			if load(item_path).new().get_quality() == quality:
				possible_results.push_back(item_path)

	assert(not possible_results.is_empty())
	possible_results.shuffle()
	return possible_results[0]


class Data:
	var dark_souls: int = 0

	var kills: Dictionary = {}

	var ignored_rooms: PackedStringArray = PackedStringArray([])

	var discovered_weapons: PackedStringArray = PackedStringArray(["res://Weapons/Melee/Katana/Katana.tscn", "res://Weapons/Melee/Spear.tscn", "res://Weapons/Melee/DragonKiller/DragonKiller.tscn", "res://Weapons/Melee/KombatHammer/KombatHammer.tscn", "res://Weapons/Melee/OrcSword/OrcSword.tscn", "res://Weapons/Melee/Scimitar/Scimitar.tscn", "res://Weapons/Melee/SharpAxe/SharpAxe.tscn", "res://Weapons/Melee/SmallAxe/SmallAxe.tscn", "res://Weapons/Melee/WarAxe/WarAxe.tscn", "res://Weapons/Melee/WarHammer/WarHammer.tscn", "res://Weapons/Melee/WarriorSword/WarriorSword.tscn", "res://Weapons/Ranged/Bows/WoodenBow/wooden_bow.tscn"])
	#"undiscovered_weapons": PackedStringArray(["res://Weapons/Melee/OrcSword/OrcSword.tscn", "res://Weapons/Melee/DragonKiller/DragonKiller.tscn", "res://Weapons/Melee/WarAxe/WarAxe.tscn"]),

	var equipped_armor: String = "res://Armors/NoArmor.gd"
	var discovered_armors: PackedStringArray = PackedStringArray(["res://Armors/CommonerClothes.gd", "res://Armors/LeatherArmor.gd", "res://Armors/MercenaryArmor.gd", "res://Armors/WarriorArmor.gd", "res://Armors/NecromancerArmor.gd", "res://Armors/improvised_armor.gd", "res://Armors/farmer_clothes.gd"])

	var discovered_permanent_items: PackedStringArray = PackedStringArray(["res://items/Passive/Permanent/StrongThrow.gd", "res://items/Passive/Permanent/ToughSkin.gd", "res://items/Passive/Permanent/EnhancedBoots.gd", "res://items/Passive/Permanent/meteor_stone.gd", "res://items/Passive/Permanent/SoulAmulet.gd", "res://items/Passive/Permanent/runes/AxeRune.gd", "res://items/Passive/Permanent/runes/HammerRune.gd", "res://items/Passive/Permanent/runes/MeleeRune.gd", "res://items/Passive/Permanent/runes/SpearRune.gd", "res://items/Passive/Permanent/runes/SwordRune.gd"])
#	"undiscovered_permanent_items": PackedStringArray(["res://items/Passive/Permanent/EnhancedBoots.gd"]),
	var discovered_temporal_items: PackedStringArray = PackedStringArray(["res://items/Passive/Temporal/magic_shields/wooden_magic_shield.gd", "res://items/Passive/Temporal/magic_shields/reinforced_magic_shield.gd", "res://items/Passive/Temporal/MagicSword.gd"])
#	"undiscovered_temporal_items": PackedStringArray(["res://items/Passive/Temporal/MagicSword.gd"]),

	var player_upgrades: Array[PlayerUpgrade] = []

	var shop_unlocked: bool = false

	func get_extra_max_hp() -> int:
		var extra_hp: int = 0

		for player_upgrade: PlayerUpgrade in player_upgrades:
			if player_upgrade is AdditionalHeart:
				extra_hp += 4 * player_upgrade.amount
				break

		return extra_hp

	static func from_dic(dic: Dictionary) -> Data:
		var data: Data = Data.new()

		for key: String in dic.keys():
			if data.get(key) != null:
				match key:
					"player_upgrades":
						for player_upgrade_dic: Dictionary in dic.player_upgrades:
							data.player_upgrades.push_back(PlayerUpgrade.from_dic(player_upgrade_dic))
					_:
						data.set(key, dic[key])
			else:
				printerr("Data: Invalid property: " + key)

		return data

	func to_dic() -> Dictionary:
		var dic: Dictionary = {}

		for property_dic: Dictionary in get_property_list():
			assert(property_dic.name is String)
			var property_name: StringName = property_dic.name
			if property_name in ["RefCounted", "script", "Built-in script"]:
				continue
			match property_name:
				"player_upgrades":
					var a: Array[Dictionary] = []

					for player_upgrade: PlayerUpgrade in player_upgrades:
						a.push_back(player_upgrade.to_dic())

					dic[property_name] = a
				_:
					dic[property_name] = get(property_name)

		return dic
