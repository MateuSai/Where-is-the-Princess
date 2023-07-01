extends Node

const USER_FOLDER: String = "user://"
const ROOMS_FOLDER_NAME: String = "rooms/"
const ARMORS_FOLDER_NAME: String = "armors/"

var num_floor: int = 0

var hp: int = 4
var weapon_stats: Array[WeaponStats] = []
var equipped_weapon_index: int = 0
var coins: int = 0

var mods: Dictionary = {
	rooms = [],
}

var custom_rooms: Array[PackedScene] = []


func _ready() -> void:
	var user_dir: DirAccess = DirAccess.open(USER_FOLDER)
	assert(user_dir) # Siempre deberiamos poder abrir el directorio del usuario
	if not user_dir.dir_exists(ROOMS_FOLDER_NAME):
		print("Can't find the rooms directory, creating it...")
		user_dir.make_dir(ROOMS_FOLDER_NAME)
	if not user_dir.dir_exists(ARMORS_FOLDER_NAME):
		print("Can't find the armors directory, creating it...")
		user_dir.make_dir(ARMORS_FOLDER_NAME)

	for room_path in _get_mod_room_paths():
		mods.rooms.push_back(Mod.new(room_path))


func _get_mod_room_paths() -> Array:
	var room_paths: Array = []
	var rooms_folder: DirAccess = DirAccess.open(USER_FOLDER + ROOMS_FOLDER_NAME)
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
	num_floor = 0

	hp = 4
	weapon_stats = []
	equipped_weapon_index = 0
	coins = 0


class Mod:
	var resource_path: String
	var enabled: bool = true

	@warning_ignore("shadowed_variable")
	func _init(resource_path: String) -> void:
		self.resource_path = resource_path
