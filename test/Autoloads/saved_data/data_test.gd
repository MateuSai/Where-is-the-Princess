class_name DataTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

const __source: String = 'res://Autoloads/saved_data/data.gd'

var data: Data = Data.new()


func test_discovered_weapons() -> void:
	#var data: Data = Data.new()

	for weapon_path: String in data.get_discovered_weapons():
		assert_bool(FileAccess.file_exists(weapon_path))
		assert_bool(weapon_path.get_extension() == "tscn")
		assert_object(auto_free(load(weapon_path).instantiate())).is_instanceof(Weapon)


func test_discovered_armors() -> void:
	#var data: Data = Data.new()

	assert_bool(FileAccess.file_exists(data.equipped_armor))
	assert_bool(data.equipped_armor.get_extension() == "gd")
	assert_object(load(data.equipped_armor).new()).is_instanceof(Armor)

	for armor_path: String in data.get_discovered_armors():
		assert_bool(FileAccess.file_exists(armor_path))
		assert_bool(armor_path.get_extension() == "gd")
		assert_object(load(armor_path).new()).is_instanceof(Armor)


func test_discovered_permanent_items() -> void:
	for item_path: String in data.get_discovered_permanent_items():
		assert_bool(FileAccess.file_exists(item_path))
		assert_bool(item_path.get_extension() == "gd")
		assert_object(load(item_path).new()).is_instanceof(PermanentPassiveItem)


func test_discovered_temporal_items() -> void:
	for item_path: String in data.get_discovered_temporal_items():
		assert_bool(FileAccess.file_exists(item_path))
		assert_bool(item_path.get_extension() == "gd")
		assert_object(load(item_path).new()).is_instanceof(TemporalPassiveItem)
