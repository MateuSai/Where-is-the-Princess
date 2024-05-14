class_name BiomeConf

const SCHEMA_PATH: String = "res://Rooms/Biomes/biome_conf_schema.json"

const DEFAULT_NUM_COMBAT_ROOMS: int = 5
const DEFAULT_NUM_CHEST_ROOMS: int = 2
const DEFAULT_NUM_SPECIAL_ROOMS: int = 1
const DEFAULT_WEAPONS_ON_FLOOR: Array[String] = []
const DEFAULT_NUM_WEAPONS_ON_FLOOR_PER_TILE: float = 0.01

var name: String = "BIOME_NAME_GOES_HERE"

var day_night_cycle: bool = true
## [String] with hexadecimal values. 2 digits for each order in order red, green, blue. For example, [code]"ff0000"[/code] is red, [code]"ffff00"[/code] is yellow, and [code]"000000"[/code] is black.
var background_color: String = "1a1c00"
## Same as [member background_color]. A [String] with hexadecimal values. 2 digits for each order in order red, green, blue. For example, [code]"ff0000"[/code] is red, [code]"ffff00"[/code] is yellow, and [code]"000000"[/code] is black.
var light_color: String = "878787"

var corridor_atlas_id: int = 0
var room_atlas_id: int = 0
## Extra margin of the room region used to separate the rooms. It can also be negative, but in that case be careful not to put one room on top of another
var room_rect_margin: int = 48
## Max length of the corridors in tiles. Generation will restart if there is a corridor that surpasses this length
var max_corridor_length: int = 45
## By default, it will just stop adding extra connections when the corridor length exceeds [member max_corridor_length]. If changed to true, the generation will restart if we find a corridor that exceeds [member max_corridor_length] before the desired number of extra connections has been reached
var restart_generation_if_extra_connections_exceed_max_corridor_length: bool = false
var extra_connections: float = 0.5
var minimap_tileset: String

var vertical_door_texture: String = "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/doors/forest_vertical_door_canvas_texture.tres"
var horizontal_down_door_texture: String = "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/doors/forest_horizontal_door_canvas_texture.tres"
var horizontal_up_door_texture: String = "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/doors/forest_horizontal_door_canvas_texture.tres"

var corridor_lights_type: String = "tiki"
var vertical_corridor_symmetric_lights: bool = false

var corridor_floor_tiles_coor: Array[Array] = []

var default_num_combat_rooms: int = DEFAULT_NUM_COMBAT_ROOMS
var default_num_chest_rooms: int = DEFAULT_NUM_CHEST_ROOMS
var default_num_special_rooms: int = DEFAULT_NUM_SPECIAL_ROOMS
var default_weapons_on_floor: Array = DEFAULT_WEAPONS_ON_FLOOR
var default_num_weapons_on_floor_per_tile: float = DEFAULT_NUM_WEAPONS_ON_FLOOR_PER_TILE
var levels: Array[Level] = []

var music: String = ""
var music_volume_db: float = 0.0

var encyclopedia_background: String = ""

var weather_modificators: Array[WeatherModificator] = []
var temperature: float = 20.0

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
				"weather_modificators":
					for weather_modificator_path: String in dic.weather_modificators:
						data.weather_modificators.push_back(load(weather_modificator_path).new())
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
	## If not specified, it will take [member BiomeConf.default_num_chest_rooms]
	var num_chest_rooms: int = -1
	## If not specified, it will take [member BiomeConf.default_num_special_rooms]
	var num_special_rooms: int = -1

	var overwrite_start_rooms: Array = [""]
	var overwrite_combat_rooms: Array = [""]
	var overwrite_chest_rooms: Array = [""]
	var overwrite_end_rooms: Dictionary = {}

	var overwrite_weapons_on_floor: Array = [""]
	var overwrite_num_weapons_on_floor_per_tile: float = -1.0

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

		if level.num_combat_rooms == - 1:
			if biome_dic.has("default_num_combat_rooms"):
				level.num_combat_rooms = biome_dic.default_num_combat_rooms
			else:
				level.num_combat_rooms = BiomeConf.DEFAULT_NUM_COMBAT_ROOMS
		if level.num_chest_rooms == - 1:
			if biome_dic.has("default_num_chest_rooms"):
				level.num_chest_rooms = biome_dic.default_num_chest_rooms
			else:
				level.num_chest_rooms = BiomeConf.DEFAULT_NUM_CHEST_ROOMS
		if level.num_special_rooms == - 1:
			if biome_dic.has("default_num_special_rooms"):
				level.num_special_rooms = biome_dic.default_num_special_rooms
			else:
				level.num_special_rooms = BiomeConf.DEFAULT_NUM_SPECIAL_ROOMS

		if level.overwrite_weapons_on_floor.size() == 1 and level.overwrite_weapons_on_floor[0].is_empty():
			if biome_dic.has("default_weapons_on_floor"):
				level.overwrite_weapons_on_floor = biome_dic.default_weapons_on_floor
			else:
				Log.debug("Using default weapons on floor")
				level.overwrite_weapons_on_floor = BiomeConf.DEFAULT_WEAPONS_ON_FLOOR
		if level.overwrite_num_weapons_on_floor_per_tile == - 1:
			if biome_dic.has("default_num_weapons_on_floor_per_tile"):
				level.overwrite_num_weapons_on_floor_per_tile = biome_dic.default_num_weapons_on_floor_per_tile
			else:
				level.overwrite_num_weapons_on_floor_per_tile = BiomeConf.DEFAULT_NUM_WEAPONS_ON_FLOOR_PER_TILE

		return level

	func get_overwrite_end_rooms(to: String) -> PackedStringArray:
		to = to.to_lower()
		if overwrite_end_rooms.has(to):
			return PackedStringArray(overwrite_end_rooms[to])
		else:
			return PackedStringArray([""])

	func get_exit_names() -> Array:
		return overwrite_end_rooms.keys()
