class_name PermanentPassiveItem extends PassiveItem

const CURSED_ITEMS_DEFAULT_FODER_PATH: String = "res://items/Passive/Permanent/cursed/"


## This function will be executed when the player picks up the passive item
func equip(_player: Player) -> void:
	pass


func unequip(_player: Player) -> void:
	pass


func get_cursed_version_path() -> String:
	var path: String = CURSED_ITEMS_DEFAULT_FODER_PATH.path_join((get_script() as GDScript).get_path().get_basename().get_file() + "_cursed.gd")
	if FileAccess.file_exists(path):
		return path
	else:
		return ""
