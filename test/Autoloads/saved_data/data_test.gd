class_name DataTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

const __source: String = 'res://Autoloads/saved_data/data.gd'

var data: Data = Data.new()


func test_available_weapons() -> void:
	for weapon_path: String in data.get_available_weapons():
		assert_bool(FileAccess.file_exists(weapon_path))
		assert_bool(weapon_path.get_extension() == "tscn")
		assert_object(auto_free(load(weapon_path).instantiate())).is_instanceof(Weapon)


func test_available_armors() -> void:
	assert_bool(FileAccess.file_exists(data.equipped_armor))
	assert_bool(data.equipped_armor.get_extension() == "gd")
	assert_object(load(data.equipped_armor).new()).is_instanceof(Armor)

	for armor_path: String in data.get_available_armors():
		assert_bool(FileAccess.file_exists(armor_path))
		assert_bool(armor_path.get_extension() == "gd")
		var armor: Armor = load(armor_path).new()
		assert_object(armor).is_instanceof(Armor)
		assert_bool(armor.get_icon() != null)
		assert_bool(armor.get_sprite_sheet() != null)


func test_available_permanent_items() -> void:
	for item_path: String in data.get_available_permanent_items():
		assert_bool(FileAccess.file_exists(item_path))
		assert_bool(item_path.get_extension() == "gd")
		var item: PermanentPassiveItem = load(item_path).new()
		assert_object(item).is_instanceof(PermanentPassiveItem)
		assert_bool(item.get_icon() != null)


func test_available_temporal_items() -> void:
	for item_path: String in data.get_available_temporal_items():
		assert_bool(FileAccess.file_exists(item_path))
		assert_bool(item_path.get_extension() == "gd")
		var item: TemporalPassiveItem = load(item_path).new()
		assert_object(item).is_instanceof(TemporalPassiveItem)
		assert_bool(item.get_icon() != null)


func test_completed_dialogue() -> void:
	data.add_completed_dialogue("Test dialogue")
	assert_bool(data.has_completed_dialogue("Test dialogue"))
