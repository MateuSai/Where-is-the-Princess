class_name Item extends Resource

#var icon: Texture
#
#
#@warning_ignore("shadowed_variable")
#func _initialize(item_icon: Texture) -> void:
#	icon = get_icon()
#	#icon = item_icon

enum Quality {
	COMMON,
	CHINGON,
}

## This function is executed to check if we can pick up the item. For example, we can't pick a whetstone if we have the first weapon equipped or if the weapon condition is already 100
func can_pick_up(_player: Player) -> bool:
	return true

## This function is executed when the player interacts with the item when it's on the floor
func pick_up(_player: Player) -> void:
	SavedData.statistics.add_item_times_picked_up(get_item_name().to_lower())

func get_icon() -> Texture2D:
	push_error("You must override get_icon on " + (get_script() as Script).get_path())
	return null

## This is the icon that is used on the encyclopedia
func get_big_icon() -> Texture2D:
	push_error("You must override get_big_icon on " + (get_script() as Script).get_path())
	return null

func get_quality() -> Quality:
	return Quality.COMMON

func get_coin_cost() -> int:
	return 10

func get_dark_soul_cost() -> int:
	return 1

func get_script_path() -> String:
	return (get_script() as Script).get_path()

func get_id() -> String:
	return get_script_path().get_basename().get_file().to_snake_case()

func get_item_name() -> String:
	return get_script_path().get_basename().get_file().to_snake_case().to_upper()

func get_item_description() -> String:
	return get_item_name() + "_DESCRIPTION"

func get_item_description_more() -> String:
	return get_item_description() + "_MORE"
