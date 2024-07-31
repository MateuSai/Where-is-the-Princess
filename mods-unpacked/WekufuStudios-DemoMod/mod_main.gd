extends Node

const MYMODNAME_MOD_DIR: String = "WekufuStudios-DemoMod/"
const MYMODNAME_LOG: String = "WekufuStudios-DemoMod"

var dir: String = ""
var ext_dir: String = ""
var trans_dir: String = ""

# With ModLoader Version 6.1.0 the `modLoader` parameter has been removed.
# For more details visit: https://github.com/GodotModding/godot-mod-loader/releases/tag/v6.1.0
#func _init(_modLoader = ModLoader):
func _init() -> void:
	ModLoaderLog.info("Init", MYMODNAME_LOG)
	dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
	ext_dir = dir.path_join("extensions/")
	trans_dir = dir.path_join("translations/")

	ModLoaderMod.install_script_extension("res://mods-unpacked/WekufuStudios-DemoMod/menu_override.gd")

	# Add translations
	for file: String in DirAccess.get_files_at(trans_dir):
		if file.get_extension() == "translation":
			ModLoaderMod.add_translation(trans_dir.path_join(file))

func _ready() -> void:
	SavedData.add_volatile_room(MYMODNAME_LOG, "res://mods-unpacked/WekufuStudios-DemoMod/rooms/forest_chest_room.tscn", "forest", "special")
	SavedData.add_volatile_room(MYMODNAME_LOG, "res://mods-unpacked/WekufuStudios-DemoMod/rooms/mod_forest_combat_room.tscn", "forest", "combat")

	SavedData.add_mod_permanent_artifact("res://mods-unpacked/WekufuStudios-DemoMod/anti_acid_ring.gd")
	SavedData.data_loaded.connect(func() -> void:
		SavedData.add_mod_armor("res://mods-unpacked/WekufuStudios-DemoMod/knight_armor/knight_armor.gd")
		SavedData.add_extra_available_armor("res://mods-unpacked/WekufuStudios-DemoMod/knight_armor/knight_armor.gd")
		SavedData.add_extra_available_permanent_item("res://mods-unpacked/WekufuStudios-DemoMod/anti_acid_ring.gd")

		SavedData.add_mod_weapon("res://mods-unpacked/WekufuStudios-DemoMod/oriental_spear/oriental_spear.tscn")
		SavedData.add_extra_available_weapon("res://mods-unpacked/WekufuStudios-DemoMod/oriental_spear/oriental_spear.tscn")
	)

	ModLoaderLog.info("Done", MYMODNAME_LOG)
