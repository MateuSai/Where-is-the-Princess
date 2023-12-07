extends Node

const MYMODNAME_MOD_DIR: String = "Mateu-DemoMod/"
const MYMODNAME_LOG: String = "Mateu-DemoMod"

var dir: String = ""
var ext_dir: String = ""
var trans_dir: String = ""

# With ModLoader Version 6.1.0 the `modLoader` parameter has been removed.
# For more details visit: https://github.com/GodotModding/godot-mod-loader/releases/tag/v6.1.0
#func _init(_modLoader = ModLoader):
func _init() -> void:
	ModLoaderLog.info("Init", MYMODNAME_LOG)
	dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
	ext_dir = dir + "extensions/"
	trans_dir = dir + "translations/"

	ModLoaderMod.install_script_extension("res://mods-unpacked/Mateu-DemoMod/menu_override.gd")

	#DirAccess.copy_absolute("res://mods-unpacked/Mateu-DemoMod/KnightArmor.gd", "res://Armors/LoadedWithouthNeedToDiscoverThem/KnightArmor.gd")

	# Add extensions
	#modLoader.install_script_extension(ext_dir + "main.gd")

	# Add translations
	#modLoader.add_translation_from_resource(trans_dir + "modname_text.en.translation")


func _ready() -> void:
	SavedData.add_volatile_armor("res://mods-unpacked/Mateu-DemoMod/KnightArmor.gd")
	SavedData.add_volatile_room("res://mods-unpacked/Mateu-DemoMod/forest_chest_room.tscn", "forest", "special")

	ModLoaderLog.info("Done", MYMODNAME_LOG)
