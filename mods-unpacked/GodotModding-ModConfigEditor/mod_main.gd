extends Node


var GodotModding_Mod_Config_MOD_DIR: String = "GodotModding-ModConfig"
var GodotModding_Mod_Config_LOG_NAME: String = "GodotModding-ModConfig"

var mod_dir_path: String = ""
var extensions_dir_path: String = ""
var translations_dir_path: String = ""


func _init(modLoader: ModLoader = ModLoader) -> void:
	ModLoaderLog.info("Init", GodotModding_Mod_Config_LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(GodotModding_Mod_Config_MOD_DIR)

	# Add extensions
	install_script_extensions(modLoader)

	# Add translations
	add_translations(modLoader)


func install_script_extensions(_modLoader: ModLoader) -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")


func add_translations(_modLoader: ModLoader) -> void:
	translations_dir_path = mod_dir_path.path_join("translations")


func _ready() -> void:
	pass
	#var mod_config_dialog = load("res://mods-unpacked/GodotModding-ModConfig/content/ModSelection/ModSelection.tscn").instantiate()
	#get_tree().root.call_deferred("add_child", mod_config_dialog)


func handle_config() -> void:
	# Get the mod config
	var config: ModConfig = ModLoaderConfig.get_current_config(GodotModding_Mod_Config_MOD_DIR)
	print(JSON.stringify(config, '\t'))
