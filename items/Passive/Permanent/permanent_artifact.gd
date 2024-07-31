class_name PermanentArtifact extends Artifact

const CURSED_ITEMS_DEFAULT_FODER_PATH: String = "res://items/Passive/Permanent/cursed/"

func get_cursed_version_path() -> String:
	return PermanentArtifact.get_cursed_version_path_from_normal_version_path((get_script() as GDScript).get_path())

static func get_cursed_version_path_from_normal_version_path(normal_version_path: String) -> String:
	var path: String = CURSED_ITEMS_DEFAULT_FODER_PATH.path_join(normal_version_path.get_basename().get_file() + "_cursed.gd")
	if FileAccess.file_exists(path):
		return path
	else:
		return ""
