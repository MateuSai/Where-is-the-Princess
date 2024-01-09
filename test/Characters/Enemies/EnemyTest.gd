# GdUnit generated TestSuite
class_name EnemyextendsCharacterTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://Characters/Enemies/Enemy.gd'


func test__ready() -> void:
	assert_dict(Character.DB).is_not_empty()
	for enemy_info: Dictionary in Globals.ENEMIES.values():
		var id: String = enemy_info.path.get_file().trim_suffix(".tscn").to_snake_case()
		assert_bool(Character.DB.has(id))
