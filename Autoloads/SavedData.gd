extends Node

const BIOMES_FOLDER_PATH: String = "res://Rooms/Biomes/"

const USER_FOLDER: String = "user://"
#const MODS_FOLDER_NAME: String = "mods/"
#const MODS_CONF_FILE_NAME: String = "mods_conf.json"
const DATA_SAVE_NAME: String = "data.json"

var data: Dictionary = {
	"dark_souls": 0,

	"kills": {},

	"ignored_rooms": PackedStringArray([]),

	"discovered_weapons": PackedStringArray(["res://Weapons/Melee/Katana/Katana.tscn", "res://Weapons/Melee/Spear.tscn", "res://Weapons/Melee/DragonKiller/DragonKiller.tscn", "res://Weapons/Melee/KombatHammer/KombatHammer.tscn", "res://Weapons/Melee/OrcSword/OrcSword.tscn", "res://Weapons/Melee/Scimitar/Scimitar.tscn", "res://Weapons/Melee/SharpAxe/SharpAxe.tscn", "res://Weapons/Melee/SmallAxe/SmallAxe.tscn", "res://Weapons/Melee/WarAxe/WarAxe.tscn", "res://Weapons/Melee/WarHammer/WarHammer.tscn", "res://Weapons/Melee/WarriorSword/WarriorSword.tscn", "res://Weapons/Ranged/Bows/WoodenBow/wooden_bow.tscn"]),
	#"undiscovered_weapons": PackedStringArray(["res://Weapons/Melee/OrcSword/OrcSword.tscn", "res://Weapons/Melee/DragonKiller/DragonKiller.tscn", "res://Weapons/Melee/WarAxe/WarAxe.tscn"]),

	"equipped_armor": "res://Armors/NoArmor.gd",
	"discovered_armors": PackedStringArray(["res://Armors/CommonerClothes.gd", "res://Armors/LeatherArmor.gd", "res://Armors/MercenaryArmor.gd", "res://Armors/WarriorArmor.gd", "res://Armors/NecromancerArmor.gd", "res://Armors/improvised_armor.gd", "res://Armors/farmer_clothes.gd"]),

	"discovered_permanent_items": PackedStringArray(["res://items/Passive/Permanent/StrongThrow.gd", "res://items/Passive/Permanent/ToughSkin.gd", "res://items/Passive/Permanent/EnhancedBoots.gd", "res://items/Passive/Permanent/meteor_stone.gd", "res://items/Passive/Permanent/SoulAmulet.gd", "res://items/Passive/Permanent/runes/AxeRune.gd", "res://items/Passive/Permanent/runes/HammerRune.gd", "res://items/Passive/Permanent/runes/MeleeRune.gd", "res://items/Passive/Permanent/runes/SpearRune.gd", "res://items/Passive/Permanent/runes/SwordRune.gd"]),
#	"undiscovered_permanent_items": PackedStringArray(["res://items/Passive/Permanent/EnhancedBoots.gd"]),
	"discovered_temporal_items": PackedStringArray(["res://items/Passive/Temporal/magic_shield.gd", "res://items/Passive/Temporal/reinforced_magic_shield.gd", "res://items/Passive/Temporal/MagicSword.gd"]),
#	"undiscovered_temporal_items": PackedStringArray(["res://items/Passive/Temporal/MagicSword.gd"]),

	"shop_unlocked": false,
}

var volatile_room_paths: Dictionary = {}

var volatile_armor_paths: Array[String] = []

var volatile_permanent_item_paths: Array[String] = []
var volatile_temporal_item_paths: Array[String] = []

var run_stats: RunStats = RunStats.new()

#var mods: Array[Mod] = []

var biome_conf: Dictionary

signal dark_souls_changed(new_value: int)


func _ready() -> void:
	print("--- SavedData ---")
	# save_data()
	_load_data()
	print(data)

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
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	#print(JSON.new().stringify(data, "\t"))


func _load_data() -> void:
	var file: FileAccess = FileAccess.open(USER_FOLDER + DATA_SAVE_NAME, FileAccess.READ)
	if file:
		print("Save data found. Loading it...")
		var json: JSON = JSON.new()
		json.parse(file.get_as_text())
		data.merge(json.data, true)
	else:
		print("No save data found, using default value...")


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
	if not data.has("kills"):
		data["kills"] = {}
	if not data["kills"].has(enemy_id):
		data["kills"][enemy_id] = 0

	data["kills"][enemy_id] += 1

	save_data()


func get_biome_conf() -> Dictionary:
	return biome_conf


func get_overwrite_spawn_shape() -> Rooms.SpawnShape:
	if biome_conf.has("levels") and biome_conf.levels.has(str(SavedData.run_stats.level)) and biome_conf["levels"][str(SavedData.run_stats.level)].has("spawn_shape_type"):
		match biome_conf["levels"][str(SavedData.run_stats.level)]["spawn_shape_type"].to_lower():
			"circle":
				if biome_conf["levels"][str(SavedData.run_stats.level)].has("spawn_shape_radius"):
					var radius: float = biome_conf["levels"][str(SavedData.run_stats.level)]["spawn_shape_radius"]
					return Rooms.CircleSpawnShape.new(radius)
				else:
					printerr("Error overwritting spawn shape, you must specify a radius using the key spawn_shape_radius")
			"rectangle":
				if biome_conf["levels"][str(SavedData.run_stats.level)].has("spawn_shape_width") and biome_conf["levels"][str(SavedData.run_stats.level)].has("spawn_shape_height"):
					return Rooms.RectangleSpawnShape.new(Vector2(biome_conf["levels"][str(SavedData.run_stats.level)]["spawn_shape_width"], biome_conf["levels"][str(SavedData.run_stats.level)]["spawn_shape_height"]))
				else:
					printerr("Error overwritting spawn shape, you must specify a width and height using the keys spawn_shape_width and spawn_shape_height")

	return null


func get_vertical_corridor_symmetric_lights() -> bool:
	if biome_conf.has("vertical_corridor_symmetric_lights"):
		return biome_conf.vertical_corridor_symmetric_lights
	else:
		return false


func get_disable_horizontal_separation_steering() -> bool:
	if biome_conf.has("levels") and biome_conf.levels.has(str(SavedData.run_stats.level)) and biome_conf["levels"][str(SavedData.run_stats.level)].has("disable_horizontal_separation_steering"):
		return biome_conf["levels"][str(SavedData.run_stats.level)]["disable_horizontal_separation_steering"]
	return false


func get_num_rooms(type: String) -> int:
	if biome_conf.has("levels") and biome_conf.levels.has(str(SavedData.run_stats.level)) and biome_conf["levels"][str(SavedData.run_stats.level)].has("num_" + type + "_rooms"):
		return biome_conf.levels[str(SavedData.run_stats.level)]["num_" + type + "_rooms"]
	else:
		return biome_conf["default_num_" + type + "_rooms"]


## This function assumes all the names you put on the overwrite conf array are correct. If you you put some room names that don't exist, the game will crash
func get_overwrite_room_paths(type: String) -> Array:
	var room_paths: Array = []

	if biome_conf.has("levels") and biome_conf.levels.has(str(run_stats.level)) and biome_conf.levels[str(run_stats.level)].has("overwrite_" + type + "_rooms"):
		room_paths = biome_conf.levels[str(run_stats.level)]["overwrite_" + type + "_rooms"]
		#print(room_paths)
#		room_paths = room_paths.map(func(room_name: String) -> String:
#			return room_name + ".tscn"
#		)
		#print(room_paths)

	return room_paths


func get_overwrite_connections() -> Array:
	var connections: Array = []

	if biome_conf.has("levels") and biome_conf.levels.has(str(run_stats.level)) and biome_conf.levels[str(run_stats.level)].has("overwrite_connections"):
		connections = biome_conf.levels[str(run_stats.level)]["overwrite_connections"]

	return connections


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
		printerr("Error reading " + BIOMES_FOLDER_PATH + biome + "/conf.json" + "!")
	biome_conf = json.data


## room_type must be "combat", "end", "special" and "start"
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
func add_volatile_armor(armor_path) -> void:
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
func add_volatile_temporal_item(item_path) -> void:
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
func add_volatile_permanent_item(item_path) -> void:
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

	for item_path_array in [get_discovered_temporal_item_paths(), get_discovered_permanent_item_paths()]:
		for item_path in item_path_array:
			if load(item_path).new().get_quality() == quality:
				possible_results.push_back(item_path)

	assert(not possible_results.is_empty())
	possible_results.shuffle()
	return possible_results[0]


## This is what we use to load the stats when we changes floor or when we saves the game
class RunStats extends Resource:
	signal coins_changed(new_coins: int)

	@export var biome: String = "Forest"
	@export var level: int = 1

	@export var hp: int = 4
	@export var weapon_stats: Array[WeaponStats] = []
	@export var equipped_weapon_index: int = 0

	@export var coins: int = 30:
		set(new_coins):
			coins = new_coins
			coins_changed.emit(coins)

	@export var armor: Armor = null

	@export var permanent_passive_items: Array[PermanentPassiveItem] = []
	@export var temporal_passive_items: Array[TemporalPassiveItem] = []
