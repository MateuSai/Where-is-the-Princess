extends Node


var GodotModding_User_Profile_MOD_DIR: String = "GodotModding-UserProfile"
var GodotModding_User_Profile_LOG_NAME: String = "GodotModding-UserProfile"

var mod_dir_path: String = ""
var extensions_dir_path: String = ""
var translations_dir_path: String = ""

const USER_PROFILE_DIALOG_PATH: String = "res://mods-unpacked/GodotModding-UserProfile/content/UserProfiles.tscn"
var user_profile_dialog: UserProfilesPopup


func _init() -> void:
	ModLoaderLog.info("Init", GodotModding_User_Profile_LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(GodotModding_User_Profile_MOD_DIR)

	# Add extensions
	install_script_extensions()

	# Add translations
	add_translations()


func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")


func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")


func _ready() -> void:
	SceneTransistor.scene_changed.connect(func(new_scene_path: String) -> void:
		if new_scene_path.get_file().trim_suffix(".tscn") == "Menu":
			_add_popup()
		else:
			_remove_popup()
	)


func _add_popup() -> void:
	user_profile_dialog = (load(USER_PROFILE_DIALOG_PATH) as PackedScene).instantiate()
	get_tree().root.call_deferred("add_child", user_profile_dialog)

	handle_config()


func _remove_popup() -> void:
	if user_profile_dialog:
		user_profile_dialog.queue_free()
		user_profile_dialog = null


func handle_config() -> void:
	# Get the mod config
	var config: ModConfig = ModLoaderConfig.get_current_config(GodotModding_User_Profile_MOD_DIR)
	ModLoader.current_config_changed.connect(_on_current_config_changed)
	apply_config(config)


func apply_config(config: ModConfig) -> void:
	user_profile_dialog.call_deferred("apply_config", config)


func _on_current_config_changed(config: ModConfig) -> void:
	if config.mod_id == GodotModding_User_Profile_MOD_DIR:
		apply_config(config)
