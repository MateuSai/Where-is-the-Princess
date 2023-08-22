extends Node

const BIOMES_FOLDER_PATH: String = "res://Rooms/Biomes/"

const USER_FOLDER: String = "user://"
const MODS_FOLDER_NAME: String = "mods/"
const MODS_CONF_FILE_NAME: String = "mods_conf.json"
const DATA_SAVE_NAME: String = "data.json"

var data: Dictionary = {
	"discovered_weapons": PackedStringArray(["res://Weapons/Melee/Katana.tscn", "res://Weapons/Melee/Spear.tscn"]),

	"equipped_armor": "res://Armors/NoArmor.gd",
	"armors_discovered": PackedStringArray(["res://Armors/NoArmor.gd", "res://Armors/KnightArmor.gd", "res://Armors/MercenaryArmor.gd"]),

	"temporal_items_discovered": PackedStringArray(["res://Items/Passive/Temporal/MagicShield.gd", "res://Items/Passive/Temporal/MagicSword.gd"])
}

var run_stats: RunStats = RunStats.new()

var mods: Array[Mod] = []

var biome_conf: Dictionary


func _ready() -> void:
	print("--- SavedData ---")
	# save_data()
	_load_data()
	print(data)

	_change_biome_conf(run_stats.biome)
	# print(biome_conf)

	var user_dir: DirAccess = DirAccess.open(USER_FOLDER)
	assert(user_dir) # Siempre deberiamos poder abrir el directorio del usuario

	if not user_dir.dir_exists(MODS_FOLDER_NAME):
		print("Can't find mods folder, creating it...")
		if user_dir.make_dir(MODS_FOLDER_NAME):
			printerr("Error creating mods directory!!")
			return

	var mods_dir: DirAccess = DirAccess.open(USER_FOLDER + MODS_FOLDER_NAME)
	if mods_dir == null:
		printerr("Error opening mods directory!")
		return

	var mods_conf: Dictionary = _load_mods_conf()
	for file_name in mods_dir.get_files():
		print(file_name)
		if mods_conf.has(file_name):
			mods.push_back(Mod.from_dictionary(mods_conf[file_name]))
		else:
			mods.push_back(Mod.new(USER_FOLDER + MODS_FOLDER_NAME + file_name))
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


func save_mods_conf() -> void:
	var mods_dic: Dictionary = {}
	for mod in mods:
		mods_dic[mod.get_name()] = mod.to_dictionary()

	var file: FileAccess = FileAccess.open(USER_FOLDER + MODS_CONF_FILE_NAME, FileAccess.WRITE)
	if not file:
		printerr("Error opening " + USER_FOLDER + MODS_CONF_FILE_NAME + " for writing!! I can't save your mods configuration, bro")
		return
	file.store_string(JSON.stringify(mods_dic, "\t"))
	file.close()


func _load_mods_conf() -> Dictionary:
	var file: FileAccess = FileAccess.open(USER_FOLDER + MODS_CONF_FILE_NAME, FileAccess.READ)
	if file:
		print("Mods configuration found. Loading it...")
		var json: JSON = JSON.new()
		json.parse(file.get_as_text())
		return json.data

	return {}


func load_mods() -> void:
	if OS.has_feature("editor"):
		print("Not loading mods because they are only supported on the exported version")
		return

	for mod in mods:
		if not ProjectSettings.load_resource_pack(mod.resource_path):
			printerr("Error loading " + mod.resource_path + " mod!")


func reset_data() -> void:
	run_stats = RunStats.new()


func get_biome_conf() -> Dictionary:
	return biome_conf


func get_num_rooms(type: String) -> int:
	if biome_conf.has("levels") and biome_conf.levels.has(str(SavedData.run_stats.level)) and biome_conf["levels"][str(SavedData.run_stats.level)].has("num_" + type + "_rooms"):
		return biome_conf.levels[str(SavedData.run_stats.level)]["num_" + type + "_rooms"]
	else:
		return biome_conf["default_num_" + type + "_rooms"]


## This function assumes all the names you put on the override conf array are correct. If you you put some room names that don't exist, the game will crash
func get_override_room_names(type: String) -> Array:
	var room_names: Array = []

	if biome_conf.has("levels") and biome_conf.levels.has(str(run_stats.level)) and biome_conf.levels[str(run_stats.level)].has("override_" + type + "_rooms"):
		room_names = biome_conf.levels[str(run_stats.level)]["override_" + type + "_rooms"]
		#print(room_names)
		room_names = room_names.map(func(room_name: String) -> String:
			return room_name + ".tscn"
		)
		#print(room_names)

	return room_names


func change_biome(new_biome: String) -> void:
	_change_biome_conf(new_biome)
	run_stats.biome = new_biome
	run_stats.level = 1


func _change_biome_conf(biome: String) -> void:
	var json: JSON = JSON.new()
	if json.parse(FileAccess.open(BIOMES_FOLDER_PATH + biome + "/conf.json", FileAccess.READ).get_as_text()):
		printerr("Error reading " + BIOMES_FOLDER_PATH + biome + "/conf.json" + "!")
	biome_conf = json.data


## This is what we use to load the stats when he changes floor or when he saves the game
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
