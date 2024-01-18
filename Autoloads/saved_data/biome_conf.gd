class_name BiomeConf

const DEFAULT_NUM_COMBAT_ROOMS: int = 5
const DEFAULT_NUM_SPECIAL_ROOMS: int = 1

var name: String = "BIOME_NAME_GOES_HERE"

var background_color: String = "1a1c00"

var corridor_atlas_id: int = 0
var room_atlas_id: int = 0
## Extra margin of the room region used to separate the rooms. It can also be negative, but in that case be careful not to put one room on top of another
var room_rect_margin: int = 48
## Max length of the corridors in tiles. Generation will restart if there is a corridor that surpasses this length
var max_corridor_length: int = 45
## By default, it will just stop adding extra connections when the corridor length exceeds [member max_corridor_length]. If changed to true, the generation will restart if we find a corridor that exceeds [member max_corridor_length] before the desired number of extra connections has been reached
var restart_generation_if_extra_connections_exceed_max_corridor_length: bool = false
var extra_connections: float = 0.5
var minimap_texture: String = "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/tilesets/triple tilemap forest_minimap_sepia.png"
var vertical_door_texture: String = "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/doors/forest_vertical_door_canvas_texture.tres"
var horizontal_down_door_texture: String = "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/doors/forest_horizontal_door_canvas_texture.tres"
var horizontal_up_door_texture: String = "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/doors/forest_horizontal_door_canvas_texture.tres"

var vertical_corridor_symmetric_lights: bool = false

var corridor_floor_tiles_coor: Array[Array] = []

var default_num_combat_rooms: int = DEFAULT_NUM_COMBAT_ROOMS
var default_num_special_rooms: int = DEFAULT_NUM_SPECIAL_ROOMS
var levels: Array[Level] = []

var music: String = ""

static func from_dic(dic: Dictionary) -> BiomeConf:
	var data: BiomeConf = BiomeConf.new()

	for key: String in dic.keys():
		if data.get(key) != null:
			match key:
				"levels":
					assert(dic[key] is Dictionary)
					var levels_dic: Dictionary = dic[key]
					data.set(key, _load_levels(dic, levels_dic))
				"corridor_floor_tiles_coor":
					data.corridor_floor_tiles_coor = []
					var a: Array = dic[key]
					data.corridor_floor_tiles_coor.assign(a)
				_:
					data.set(key, dic[key])
		else:
			printerr("BiomeConf: Invalid property: " + key)

	return data

#func to_dic() -> Dictionary:
	#var dic: Dictionary = {}
#
	#for property_dic: Dictionary in get_property_list():
		#assert(property_dic.name is StringName)
		#var property_name: StringName = property_dic.name
		#if property_name in ["RefCounted", "script", "Built-in script"]:
			#continue
		#dic[property_name] = get(property_name)
#
	#return dic


static func _load_levels(biome_dic: Dictionary, levels_dic: Dictionary) -> Array[Level]:
	var arr: Array[Level] = []

	for key: String in levels_dic.keys():
		var level: int = int(key)

		while arr.size() + 1 < level:
			arr.push_back(Level.from_dic(biome_dic, {}))

		assert(levels_dic[key] is Dictionary)
		var level_dic: Dictionary = levels_dic[key]
		arr.push_back(Level.from_dic(biome_dic, level_dic))

	return arr


class Level:
	## Area in which the rooms will be spawned. It can be "circle" or "rectangle"
	var spawn_shape_type: String = "circle"
	## Width of the rectangle spawn shape. Set this only if you are using a "rectangle" shape
	var spawn_shape_width: int = 200
	## Height of the rectangle spawn shape. Set this only if you are using a "rectangle" shape
	var spawn_shape_height: int = 300
	## Radius of the circle spawn shape. Set this only if you are using a "circle" shape
	var spawn_shape_radius: int = 100
	## If this is enabled, the rooms will only move vertically when they get apart from each other
	var disable_horizontal_separation_steering: bool = false

	## By default, each room entrance can connect with many rooms, change this to true to limit it to 1
	var limit_entrance_connections_to_one: bool = false

	## If not specified, it will take [member BiomeConf.default_num_combat_rooms]
	var num_combat_rooms: int = -1
	## If not specified, it will take [member BiomeConf.default_num_special_rooms]
	var num_special_rooms: int = -1

	var overwrite_start_rooms: Array = [""]
	var overwrite_combat_rooms: Array = [""]
	var overwrite_end_rooms: Dictionary = {}

	var overwrite_connections: Array = []

	static func from_dic(biome_dic: Dictionary, level_dic: Dictionary) -> Level:
		var level: Level = Level.new()

		for key: String in level_dic.keys():
			if key.begins_with("overwrite_end"):
				var splitted_key: PackedStringArray = key.split("_")
				level.overwrite_end_rooms[splitted_key[splitted_key.size() - 2]] = level_dic[key]
			elif level.get(key) != null:
				level.set(key, level_dic[key])
			else:
				printerr("Level: Invalid property: " + key)

		if level.num_combat_rooms == -1:
			if biome_dic.has("default_num_combat_rooms"):
				level.num_combat_rooms = biome_dic.default_num_combat_rooms
			else:
				level.num_combat_rooms = BiomeConf.DEFAULT_NUM_COMBAT_ROOMS
		if level.num_special_rooms == -1:
			if biome_dic.has("default_num_special_rooms"):
				level.num_special_rooms = biome_dic.default_num_combat_rooms
			else:
				level.num_special_rooms = BiomeConf.DEFAULT_NUM_SPECIAL_ROOMS

		return level

	func get_overwrite_end_rooms(to: String) -> PackedStringArray:
		to = to.to_lower()
		if overwrite_end_rooms.has(to):
			return PackedStringArray(overwrite_end_rooms[to])
		else:
			return PackedStringArray([""])


	func get_exit_names() -> Array:
		return overwrite_end_rooms.keys()
