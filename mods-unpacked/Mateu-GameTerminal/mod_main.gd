extends Node

const GAME_TERMINAL_MOD_DIR: String = "Mateu-GameTerminal/"
const GAME_TERMINAL_LOG: String = "Mateu-GameTerminal"

var dir: String = ""
var ext_dir: String = ""
var trans_dir: String = ""

# With ModLoader Version 6.1.0 the `modLoader` parameter has been removed.
# For more details visit: https://github.com/GodotModding/godot-mod-loader/releases/tag/v6.1.0
#func _init(_modLoader = ModLoader):
func _init() -> void:
	ModLoaderLog.info("Init", GAME_TERMINAL_LOG)
	dir = ModLoaderMod.get_unpacked_dir().path_join(GAME_TERMINAL_MOD_DIR)
	ext_dir = dir.path_join("extensions/")
	trans_dir = dir.path_join("translations/")

	var debug_ui: DebugUI = load("res://ui/DebugUI.tscn").instantiate()
	ModLoaderMod.append_node_in_scene(debug_ui, "Terminal", null, "res://mods-unpacked/Mateu-GameTerminal/terminal/terminal.tscn")
	ModLoaderMod.save_scene(debug_ui, "res://ui/DebugUI.tscn")
	debug_ui.queue_free()

	# Add extensions
	#modLoader.install_script_extension(ext_dir + "main.gd")

	# Add translations
	#modLoader.add_translation_from_resource(trans_dir + "modname_text.en.translation")


func _ready() -> void:
	#print_orphan_nodes()
	ModLoaderLog.info("Done", GAME_TERMINAL_LOG)
