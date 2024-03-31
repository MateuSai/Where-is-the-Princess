class_name PermanentPassiveItem extends PassiveItem

const CURSED_ITEMS_DEFAULT_FODER_PATH: String = "res://items/Passive/Permanent/cursed/"

var effects: Array[ItemEffect] = []


## This function will be executed when the player picks up the passive item
func equip(player: Player) -> void:
	for effect: ItemEffect in effects:
		effect.enable(player)


func unequip(player: Player) -> void:
	for effect: ItemEffect in effects:
		effect.disable(player)


func get_cursed_version_path() -> String:
	var path: String = CURSED_ITEMS_DEFAULT_FODER_PATH.path_join((get_script() as GDScript).get_path().get_basename().get_file() + "_cursed.gd")
	if FileAccess.file_exists(path):
		return path
	else:
		return ""
