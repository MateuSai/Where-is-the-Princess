class_name Item extends Resource

#var icon: Texture
#
#
##@warning_ignore("shadowed_variable")
#func _initialize(item_icon: Texture) -> void:
#	icon = get_icon()
#	#icon = item_icon


## This function is executed to check if we can pick up the item. For example, we can't pick a whetstone if we have the first weapon equipped or if the weapon condition is already 100
func can_pick_up(_player: Player) -> bool:
	return true


## This function is executed when the player interacts with the item when it's on the floor
func pick_up(_player: Player) -> void:
	pass


func get_icon() -> Texture:
	printerr("You must override get_icon on " + get_script().get_path())
	return null


func get_coin_cost() -> int:
	printerr("You should override get_coin_cost on " + get_script().get_path())
	return 10


func get_dark_soul_cost() -> int:
	printerr("You should override get_dark_soul_cost on " + get_script().get_path())
	return 1
