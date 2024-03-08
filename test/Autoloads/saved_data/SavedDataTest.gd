# GdUnit generated TestSuite
class_name SavedDataTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://Autoloads/saved_data/SavedData.gd'


@warning_ignore("unused_parameter")
func test_add_enemy_times_killed(do_skip: bool = true, skip_reason: String = "Broken because add_enemy_times_killed now need access to notification container which is only available on the game") -> void:
	var skelebro_unlock_weapon_on_kills: UnlockWeaponOnKills = load("res://Characters/Enemies/skelebro/unlock_weapon_on_kills.tres")

	SavedData.statistics._enemies_statistics.erase("skelebro")

	for i: int in skelebro_unlock_weapon_on_kills.kills_necessary:
		SavedData.add_enemy_times_killed("skelebro")
		assert_int(SavedData.statistics.get_enemy_statistics("skelebro").times_killed).is_equal(i+1)

	assert_array(SavedData.get_available_weapon_paths()).contains([skelebro_unlock_weapon_on_kills.weapon_path])
