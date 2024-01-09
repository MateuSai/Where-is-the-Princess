# GdUnit generated TestSuite
class_name BiomeConfTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://Autoloads/saved_data/biome_conf.gd'

var biomes: Array[BiomeConf] = []


func before() -> void:
	for biome: String in ["forest", "sewer"]:
		SavedData.change_biome(biome)
		biomes.push_back(SavedData.get_biome_conf())


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


func test_rooms() -> void:
	for biome_conf: BiomeConf in biomes:
		for level: BiomeConf.Level in biome_conf.levels:
			if level.overwrite_start_rooms.size() > 0 and not level.overwrite_start_rooms[0].is_empty():
				for path: String in level.overwrite_start_rooms:
					assert_bool(FileAccess.file_exists(path))
					assert_bool(path.get_extension() == "tscn")
					assert_object(auto_free(load(path).instantiate())).is_instanceof(DungeonRoom)
			if level.overwrite_combat_rooms.size() > 0 and not level.overwrite_combat_rooms[0].is_empty():
				for path: String in level.overwrite_combat_rooms:
					assert_bool(FileAccess.file_exists(path))
					assert_bool(path.get_extension() == "tscn")
					assert_object(auto_free(load(path).instantiate())).is_instanceof(DungeonRoom)
