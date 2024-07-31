class_name Rune extends PermanentArtifact

const CURSED_RUNE_ITEMS_DEFAULT_FODER_PATH: String = "res://items/Passive/Permanent/cursed/runes"

func get_symbol() -> Texture2D:
	push_error("You must overwrite this function")
	return null

func get_cursed_version_path() -> String:
	return Rune.get_cursed_version_path_from_normal_version_path((get_script() as GDScript).get_path())

static func get_cursed_version_path_from_normal_version_path(normal_version_path: String) -> String:
	var path: String = CURSED_RUNE_ITEMS_DEFAULT_FODER_PATH.path_join(normal_version_path.get_basename().get_file() + "_cursed.gd")
	if FileAccess.file_exists(path):
		return path
	else:
		return ""