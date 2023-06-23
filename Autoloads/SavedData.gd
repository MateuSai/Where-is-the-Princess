extends Node

const USER_FOLDER: String = "user://"
const ROOMS_FOLDER_NAME: String = "rooms/"

var num_floor: int = 0

var hp: int = 4
var weapon_stats: Array[WeaponStats] = []
var equipped_weapon_index: int = 0
var coins: int = 0

var custom_rooms: Array[PackedScene] = []


func _ready() -> void:
	var user_dir: DirAccess = DirAccess.open(USER_FOLDER)
	assert(user_dir) # Siempre deberiamos poder abrir el directorio del usuario
	if not user_dir.dir_exists(ROOMS_FOLDER_NAME):
		print("Can't find the rooms directory, creating it...")
		user_dir.make_dir(ROOMS_FOLDER_NAME)
	else:
		var rooms_folder: DirAccess = DirAccess.open(USER_FOLDER + ROOMS_FOLDER_NAME)
		if not rooms_folder:
			printerr("Error opening rooms folder!!")
		else:
			for file_name in rooms_folder.get_files():
				print(file_name)
				var room: PackedScene = load(USER_FOLDER + ROOMS_FOLDER_NAME + file_name)
				custom_rooms.push_back(room)


func reset_data() -> void:
	num_floor = 0

	hp = 4
	weapon_stats = []
	equipped_weapon_index = 0
	coins = 0
