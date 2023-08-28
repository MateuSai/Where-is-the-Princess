extends Node

const MYMODNAME_MOD_DIR = "Mateu-DemoMod/"
const MYMODNAME_LOG = "Mateu-DemoMod"

var dir = ""
var ext_dir = ""
var trans_dir = ""

# With ModLoader Version 6.1.0 the `modLoader` parameter has been removed.
# For more details visit: https://github.com/GodotModding/godot-mod-loader/releases/tag/v6.1.0
func _init(_modLoader = ModLoader):
#func _init():
	ModLoaderLog.info("Init", MYMODNAME_LOG)
	dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
	ext_dir = dir + "extensions/"
	trans_dir = dir + "translations/"

	# Add extensions
	#modLoader.install_script_extension(ext_dir + "main.gd")

	# Add translations
	#modLoader.add_translation_from_resource(trans_dir + "modname_text.en.translation")


func _ready():
	ModLoaderLog.info("Done", MYMODNAME_LOG)
