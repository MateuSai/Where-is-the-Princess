# GdUnit generated TestSuite
class_name BiomeConfTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://Autoloads/saved_data/biome_conf.gd'

var biomes: Array[BiomeConf] = []
var other_biome_conf: BiomeConf = BiomeConf.from_dic({
	levels={
		"2"={
			overwrite_end_forest_rooms=["path/to/room1", "path/to/room2"],
			overwrite_end_sewer_rooms=["path/to/room3", "path/to/room4"],
		}
	}
})

func before() -> void:
	for biome: String in Data.ALL_VANILLA_BIOMES:
		SavedData.change_biome_by_id_or_path(biome)
		biomes.push_back(SavedData.get_biome_conf())

@warning_ignore("unused_parameter")
func test_schema(do_skip: bool=true, skip_reason: String="Schema validator does not have support for $ref") -> void:
	for biome: String in Data.ALL_VANILLA_BIOMES:
		var validator: JSONSchema = JSONSchema.new()
		var schema_file: FileAccess = FileAccess.open(BiomeConf.SCHEMA_PATH, FileAccess.READ)
		assert_object(schema_file).is_not_null()
		print(validator.validate(SavedData.get_biome_json_string_by_id_or_path(biome), schema_file.get_as_text()))

func test_minimap_texture() -> void:
	for biome_conf: BiomeConf in biomes:
		assert_bool(FileAccess.file_exists(biome_conf.minimap_texture))

func test_door_textures() -> void:
	for biome_conf: BiomeConf in biomes:
		assert_bool(FileAccess.file_exists(biome_conf.vertical_door_texture))
		assert_bool(FileAccess.file_exists(biome_conf.horizontal_down_door_texture))
		assert_bool(FileAccess.file_exists(biome_conf.horizontal_up_door_texture))

func test_music() -> void:
	for biome_conf: BiomeConf in biomes:
		assert_bool(biome_conf.music.is_empty() or FileAccess.file_exists(biome_conf.music))

func test_encyclopedia_background() -> void:
	for biome_conf: BiomeConf in biomes:
		assert_bool(FileAccess.file_exists(biome_conf.encyclopedia_background))

func test_rooms() -> void:
	for biome_conf: BiomeConf in biomes:
		for level: BiomeConf.Level in biome_conf.levels:
			if level.overwrite_start_rooms.size() > 0 and not level.overwrite_start_rooms[0].is_empty():
				for path: String in level.overwrite_start_rooms:
					_check_room(path)
			if level.overwrite_combat_rooms.size() > 0 and not level.overwrite_combat_rooms[0].is_empty():
				for path: String in level.overwrite_combat_rooms:
					_check_room(path)
			for overwrite_end_rooms: Array in level.overwrite_end_rooms.values():
				if overwrite_end_rooms.size() > 0 and not overwrite_end_rooms[0].is_empty():
					for path: String in overwrite_end_rooms:
						_check_room(path)

func _check_room(path: String) -> void:
	assert_bool(FileAccess.file_exists(path))
	assert_bool(path.get_extension() == "tscn")
	var room: DungeonRoom = auto_free(load(path).instantiate())
	assert_object(room).is_instanceof(DungeonRoom)

	for enemy_marker: EnemyMarker in room.get_node("EnemyPositions").get_children():
		assert_object(Globals.get_enemy_scene(enemy_marker.enemy_name)).is_not_null()

func test_get_overwrite_end_rooms() -> void:
	assert_array(other_biome_conf.levels).has_size(2)
	assert_array(other_biome_conf.levels[1].get_overwrite_end_rooms("forest")).contains_exactly(["path/to/room1", "path/to/room2"])
	assert_array(other_biome_conf.levels[1].get_overwrite_end_rooms("sewer")).contains_exactly(["path/to/room3", "path/to/room4"])

func test_default_weapons_on_floor() -> void:
	for biome: BiomeConf in biomes:
		for weapon_on_floor_path: String in biome.default_weapons_on_floor:
			_test_weapon_path(weapon_on_floor_path)

func test_override_weapons_on_floor() -> void:
	for biome: BiomeConf in biomes:
		for level: BiomeConf.Level in biome.levels:
			for weapon_on_floor_path: String in level.overwrite_weapons_on_floor:
				_test_weapon_path(weapon_on_floor_path)

func _test_weapon_path(weapon_path: String) -> void:
	assert_bool(FileAccess.file_exists(weapon_path))
	assert_bool(weapon_path.get_extension() == "tscn")
	assert_object(auto_free(load(weapon_path).instantiate())).is_instanceof(Weapon)
	assert_object(Weapon.get_data(Weapon.get_id_from_path(weapon_path))).is_not_null()

func test_get_exit_names() -> void:
	assert_array(other_biome_conf.levels[1].get_exit_names()).has_size(2).contains_exactly(["forest", "sewer"])
