extends Node

const BIOMES_PATH_PATH: String = "res://Rooms/biomes_path.json"

const USER_FOLDER: String = "user://"
const MODS_FOLDER_NAME: String = "mods/"
const DATA_SAVE_NAME: String = "data.json"

var data: Dictionary = {
	"equipped_armor": "res://Armors/NoArmor.gd",
	"armors_discovered": PackedStringArray(["res://Armors/NoArmor.gd", "res://Armors/KnightArmor.gd", "res://Armors/MercenaryArmor.gd"]),

	"temporal_items_discovered": PackedStringArray(["res://Items/Passive/Temporal/MagicShield.gd"])
}

var run_stats: RunStats = RunStats.new()

var mods: Dictionary = {

}

var biomes_path: Dictionary


func _ready() -> void:
	# save_data()
	_load_data()
	print(data)

	var json: JSON = JSON.new()
	if json.parse(FileAccess.open(BIOMES_PATH_PATH, FileAccess.READ).get_as_text()):
		printerr("Error reading " + BIOMES_PATH_PATH + "!")
	biomes_path = json.data
	# print(biomes_path)

	var user_dir: DirAccess = DirAccess.open(USER_FOLDER)
	assert(user_dir) # Siempre deberiamos poder abrir el directorio del usuario

	if not user_dir.dir_exists(MODS_FOLDER_NAME):
		print("Can't find mods folder, creating it...")
		if user_dir.make_dir(MODS_FOLDER_NAME):
			printerr("Error creating mods directory!!")
			return

	if OS.has_feature("editor"):
		print("Not loading mods because they are only supported on the exported version")
	else:
		var mods_dir: DirAccess = DirAccess.open(USER_FOLDER + MODS_FOLDER_NAME)
		if mods_dir == null:
			printerr("Error opening mods directory!")
			return

		for file_name in mods_dir.get_files():
			print(file_name)
			mods[file_name] = USER_FOLDER + MODS_FOLDER_NAME + file_name
			if not ProjectSettings.load_resource_pack(USER_FOLDER + MODS_FOLDER_NAME + file_name):
				printerr("Error loading " + USER_FOLDER + MODS_FOLDER_NAME + file_name + " mod!")
			#var room: PackedScene = load(USER_FOLDER + ROOMS_FOLDER_NAME + file_name)
			#custom_rooms.push_back(room)
			#room_paths.push_back(USER_FOLDER + ROOMS_FOLDER_NAME + file_name)


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


func reset_data() -> void:
	run_stats = RunStats.new()


func get_biome_info() -> Dictionary:
	return biomes_path[run_stats.biome]


func change_biome(new_biome: String) -> void:
	run_stats.biome = new_biome
	run_stats.level = 1


## This is what we use to load the stats when he changes floor or when he saves the game
class RunStats extends Resource:
	signal coins_changed(new_coins: int)

	@export var biome: String = "Dungeon"
	@export var level: int = 1

	@export var hp: int = 4
	@export var weapon_stats: Array[WeaponStats] = []
	@export var equipped_weapon_index: int = 0
	@export var coins: int = 0:
		set(new_coins):
			coins = new_coins
			coins_changed.emit(coins)

	@export var armor: Armor = null

	@export var permanent_passive_items: Array[PermanentPassiveItem] = []
	@export var temporal_passive_items: Array[TemporalPassiveItem] = []
