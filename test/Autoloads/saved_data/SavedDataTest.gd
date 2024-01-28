# GdUnit generated TestSuite
class_name SavedDataTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://Autoloads/saved_data/SavedData.gd'


func test_add_enemy_kill() -> void:
	var skelebro_unlock_weapon_on_kills: UnlockWeaponOnKills = load("res://Characters/Enemies/skelebro/unlock_weapon_on_kills.tres")

	SavedData.data._enemies_data.erase("skelebro")

	for i: int in skelebro_unlock_weapon_on_kills.kills_necessary:
		SavedData.add_enemy_kill("skelebro")
		assert_int(SavedData.data.get_enemy_data("skelebro").kills).is_equal(i+1)

	assert_array(SavedData.get_available_weapon_paths()).contains([skelebro_unlock_weapon_on_kills.weapon_path])
