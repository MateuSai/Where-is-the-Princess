extends Node

const USER_FOLDER: String = "user://"
const MODS_FOLDER_NAME: String = "mods/"
const ROOMS_FOLDER_NAME: String = "rooms/"
const ARMORS_FOLDER_NAME: String = "armors/"
const WEAPONS_FOLDER_NAME: String = "weapons/"

var run_stats: RunStats = RunStats.new()

var mods: Dictionary = {
	rooms = [],
}


func _ready() -> void:
	var user_dir: DirAccess = DirAccess.open(USER_FOLDER)
	assert(user_dir) # Siempre deberiamos poder abrir el directorio del usuario

	if not user_dir.dir_exists(MODS_FOLDER_NAME):
		print("Can't find mods folder, creating it along his subfolders...")
		for sub_folder in [ROOMS_FOLDER_NAME, ARMORS_FOLDER_NAME, WEAPONS_FOLDER_NAME]:
			if user_dir.make_dir_recursive(MODS_FOLDER_NAME + sub_folder):
				printerr("Error creating " + sub_folder + "!")
	else:
		for sub_folder in [ROOMS_FOLDER_NAME, ARMORS_FOLDER_NAME, WEAPONS_FOLDER_NAME]:
			if not user_dir.dir_exists(MODS_FOLDER_NAME + sub_folder):
				print("Can't find the " + sub_folder + " directory, creating it...")
				if user_dir.make_dir_recursive(MODS_FOLDER_NAME + sub_folder):
					printerr("Error creating " + sub_folder + "!")

	for room_path in _get_mod_room_paths():
		mods.rooms.push_back(Mod.new(room_path))


func _get_mod_room_paths() -> Array:
	var room_paths: Array = []
	var rooms_folder: DirAccess = DirAccess.open(USER_FOLDER + MODS_FOLDER_NAME + ROOMS_FOLDER_NAME)
	if not rooms_folder:
		printerr("Error opening rooms folder!!")
	else:
		for file_name in rooms_folder.get_files():
			#print(file_name)
			#var room: PackedScene = load(USER_FOLDER + ROOMS_FOLDER_NAME + file_name)
			#custom_rooms.push_back(room)
			room_paths.push_back(USER_FOLDER + ROOMS_FOLDER_NAME + file_name)

	return room_paths


func reset_data() -> void:
	run_stats = RunStats.new()


## This is what we use to load the stats when he changes floor or when he saves the game
class RunStats extends Resource:
	signal coins_changed(new_coins: int)

	@export var num_floor: int = 0
	@export var hp: int = 4
	@export var weapon_stats: Array[WeaponStats] = []
	@export var equipped_weapon_index: int = 0
	@export var coins: int = 0:
		set(new_coins):
			coins = new_coins
			coins_changed.emit(coins)

	@export var armor: Armor = null
