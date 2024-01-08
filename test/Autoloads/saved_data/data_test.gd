class_name DataTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

const __source: String = 'res://Autoloads/saved_data/data.gd'

var data: Data = Data.new()


func test_discovered_weapons() -> void:
	#var data: Data = Data.new()

	for weapon_path: String in data.discovered_weapons:
		assert_bool(FileAccess.file_exists(weapon_path))
		assert_bool(weapon_path.get_extension() == "tscn")


func test_discovered_armors() -> void:
	#var data: Data = Data.new()

	for armor_path: String in data.discovered_armors:
		assert_bool(FileAccess.file_exists(armor_path))
		assert_bool(armor_path.get_extension() == "gd")
