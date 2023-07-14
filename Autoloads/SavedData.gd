extends Node

const BIOMES_PATH_PATH: String = "res://Rooms/biomes_path.json"

const USER_FOLDER: String = "user://"
const MODS_FOLDER_NAME: String = "mods/"

var run_stats: RunStats = RunStats.new()

var mods: Dictionary = {

}

var biomes_path: Dictionary


func _ready() -> void:
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

	var mods_dir: DirAccess = DirAccess.open(USER_FOLDER + MODS_FOLDER_NAME)
	if mods_dir == null:
		printerr("Error opening mods directory!")
		return

	for file_name in mods_dir.get_files():
		print(file_name)
		mods[file_name] = USER_FOLDER + MODS_FOLDER_NAME + file_name
		#var room: PackedScene = load(USER_FOLDER + ROOMS_FOLDER_NAME + file_name)
		#custom_rooms.push_back(room)
		#room_paths.push_back(USER_FOLDER + ROOMS_FOLDER_NAME + file_name)

#	for room_path in _get_mod_room_paths():
#		mods.rooms.push_back(Mod.new(room_path))


func reset_data() -> void:
	run_stats = RunStats.new()


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
