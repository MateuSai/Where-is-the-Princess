class_name DataTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

const __source: String = 'res://Autoloads/saved_data/data.gd'

var data: Data = Data.new()


func test_weapons() -> void:
	assert_array(data.ALL_VANILLA_WEAPONS).contains(data.AVAILABLE_WEAPONS_FROM_START)

	for weapon_path: String in data.ALL_VANILLA_WEAPONS:
		assert_bool(FileAccess.file_exists(weapon_path))
		assert_bool(weapon_path.get_extension() == "tscn")
		assert_object(auto_free(load(weapon_path).instantiate())).is_instanceof(Weapon)
		assert_object(Weapon.get_data(Weapon.get_id_from_path(weapon_path))).is_not_null()


func test_armors() -> void:
	assert_array(data.ALL_VANILLA_ARMORS).contains(data.AVAILABLE_ARMORS_FROM_START)

	assert_bool(FileAccess.file_exists(data.equipped_armor))
	assert_bool(data.equipped_armor.get_extension() == "gd")
	assert_object(load(data.equipped_armor).new()).is_instanceof(Armor)

	for armor_path: String in data.ALL_VANILLA_ARMORS:
		assert_bool(FileAccess.file_exists(armor_path))
		assert_bool(armor_path.get_extension() == "gd")
		var armor: Armor = load(armor_path).new()
		assert_object(armor).is_instanceof(Armor)
		assert_bool(armor.get_icon() != null)
		assert_bool(armor.get_sprite_sheet() != null)


func test_permanent_items() -> void:
	assert_array(data.ALL_VANILLA_PERMANENT_ITEMS).contains(data.AVAILABLE_PERMANENT_ITEMS_FROM_START)

	for item_path: String in data.ALL_VANILLA_PERMANENT_ITEMS:
		assert_bool(FileAccess.file_exists(item_path))
		assert_bool(item_path.get_extension() == "gd")
		var item: PermanentPassiveItem = load(item_path).new()
		assert_object(item).is_instanceof(PermanentPassiveItem)
		assert_bool(item.get_icon() != null)


func test_temporal_items() -> void:
	assert_array(data.ALL_VANILLA_TEMPORAL_ITEMS).contains(data.AVAILABLE_TEMPORAL_ITEMS_FROM_START)

	for item_path: String in data.ALL_VANILLA_TEMPORAL_ITEMS:
		assert_bool(FileAccess.file_exists(item_path))
		assert_bool(item_path.get_extension() == "gd")
		var item: TemporalPassiveItem = load(item_path).new()
		assert_object(item).is_instanceof(TemporalPassiveItem)
		assert_bool(item.get_icon() != null)


func test_completed_dialogue() -> void:
	data.add_completed_dialogue("Test dialogue")
	assert_bool(data.has_completed_dialogue("Test dialogue"))
