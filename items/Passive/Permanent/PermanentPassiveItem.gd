class_name PermanentPassiveItem extends PassiveItem

const CURSED_ITEMS_DEFAULT_FODER_PATH: String = "res://items/Passive/Permanent/cursed/"

func get_cursed_version_path() -> String:
	var path: String = CURSED_ITEMS_DEFAULT_FODER_PATH.path_join((get_script() as GDScript).get_path().get_basename().get_file() + "_cursed.gd")
	if FileAccess.file_exists(path):
		return path
	else:
		return ""
