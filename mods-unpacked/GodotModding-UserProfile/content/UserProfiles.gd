extends Popup
class_name UserProfilesPopup

@export var user_profile_section: PackedScene
#@export var text_select_profile := "Select Profile"
const TEXT_RESTART: String = "A_GAME_RESTART_IS_REQUIRED_TO_APPLY_THE_SETTINGS"
const TEXT_PROFILE_CREATE_ERROR: String = "TEXT_PROFILE_CREATE_ERROR"
const TEXT_PROFILE_SELECT_ERROR: String = "TEXT_PROFILE_SELECT_ERROR"
const TEXT_PROFILE_DELETE_ERROR: String = "TEXT_PROFILE_DELETE_ERROR"
const TEXT_MOD_ENABLE_ERROR: String = "TEXT_MOD_ENABLE_ERROR"
const TEXT_MOD_DISABLE_ERROR: String = "TEXT_MOD_DISABLE_ERROR"
const TEXT_MOD_CURRENT_CONFIG_CHANGE_ERROR: String = "TEXT_MOD_CURRENT_CONFIG_CHANGE_ERROR"
const TEXT_CURRENT_PROFILE: String = "TEXT_CURRENT_PROFILE"

# I can't put a material on the PopupPanel, so I'm using the material of his panel.
# It seems it always have the same name, you can check it on the remote tab
# and change it if it's different on your case
#@onready var panel: Panel = $"@Panel@16"
@onready var label_select_profile: Label = $"%LabelSelectProfile"
@onready var user_profile_sections: VBoxContainer = $"%UserProfileSections"
@onready var profile_select: OptionButton = $"%ProfileSelect"
@onready var popup_new_profile: PopupPanel = $"%PopupNewProfile"
@onready var input_profile_name: LineEdit = $"%InputProfileName"
#@onready var button_profile_name_submit: Button = $"%ButtonProfileNameSubmit"
#@onready var button_new_profile: Button = $"%ButtonNewProfile"
@onready var info_text: Label = $"%InfoText"
@onready var restart_button: Button = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/RestartButton

func _ready() -> void:
#	panel.material = ShaderMaterial.new()
#	panel.material.shader = load("res://mods-unpacked/GodotModding-UserProfile/assets/shader/blur.tres")

	hide()

	_populate_profile_select()
	_generate_user_profile_section()

	ModLoader.current_config_changed.connect(_on_ModLoader_current_config_changed)

# In Godot 4 a popup does not receive input until it's visible,
# so we can't use this anymore.
#
# To make the popup visible,
# call get_tree().root.get_node("UserProfiles").popup_centered()
# from any node. For example, when you press a button
#func _input(event) -> void:
#	if event is InputEventKey:
#		if event.pressed and event.keycode == KEY_U:
#			popup_centered() if not visible else hide()

func apply_config(_config: ModConfig) -> void:
	return
#	label_select_profile.text = config.data.select_profile_text
#
#	var material_settings: Dictionary = config.data.material_settings
#
#	panel.material.set_shader_parameter("animate", material_settings.animate)
#	panel.material.set_shader_parameter("square_scale", material_settings.square_scale)
#	panel.material.set_shader_parameter("blur_amount", material_settings.blur_amount)
#	panel.material.set_shader_parameter("mix_amount", material_settings.mix_amount)
#	panel.material.set_shader_parameter("color_over", Color(material_settings.color))

func _update_ui() -> void:
	# Update the profile select list
	_populate_profile_select()

	# Update the Setting list
	_generate_user_profile_section()

func _populate_profile_select() -> void:
	var index_current_profile: int

	profile_select.clear()

	for user_profile: ModUserProfile in ModLoaderUserProfile.get_all_as_array():
		var is_current_profile: bool = true if ModLoaderUserProfile.get_current().name == user_profile.name else false
		profile_select.add_item(tr(TEXT_CURRENT_PROFILE) % user_profile.name if is_current_profile else user_profile.name)

		# Get the item index of the current profile
		if is_current_profile:
			index_current_profile = profile_select.get_item_count() - 1

	# Select current profile
	profile_select.select(index_current_profile)

func _generate_user_profile_section() -> void:
	for section: ModList in user_profile_sections.get_children():
		section.clear_grid()
		section.generate_grid(ModLoaderUserProfile.get_current())

func _on_ButtonNewProfile_pressed() -> void:
	popup_new_profile.popup_centered()

func _on_ButtonDeleteProfile_pressed() -> void:
	var profile_to_delete: ModUserProfile = ModLoaderStore.current_user_profile
	# Switch to default profile
	if not ModLoaderUserProfile.set_profile(ModLoaderUserProfile.get_profile("default")):
		_set_info_text(TEXT_PROFILE_SELECT_ERROR)
		return
	# Delete the profile
	if not ModLoaderUserProfile.delete_profile(profile_to_delete):
		_set_info_text(TEXT_PROFILE_DELETE_ERROR)
		return

	_update_ui()

func _on_ButtonProfileNameSubmit_pressed() -> void:
	# Create new User Profile
	if not ModLoaderUserProfile.create_profile(input_profile_name.text):
		# If there was an error creating the profile
		# Add error message to the info text label
		_set_info_text(TEXT_PROFILE_CREATE_ERROR)
		# And return early
		return

	_update_ui()

	# Close popup
	popup_new_profile.hide()

func _on_ProfileSelect_item_selected(index: int) -> void:
	var user_profile: ModUserProfile = ModLoaderUserProfile.get_profile(profile_select.get_item_text(index))
	if not ModLoaderUserProfile.set_profile(user_profile):
		_set_info_text(TEXT_PROFILE_SELECT_ERROR)
		return

	_update_ui()

	_set_info_text(TEXT_RESTART)

func _on_ModList_mod_is_active_changed(mod_id: String, is_active: bool) -> void:
	if is_active:
		if not ModLoaderUserProfile.enable_mod(mod_id):
			_set_info_text(TEXT_MOD_ENABLE_ERROR)
			return
	else:
		if not ModLoaderUserProfile.disable_mod(mod_id):
			_set_info_text(TEXT_MOD_DISABLE_ERROR)
			return

	_set_info_text(TEXT_RESTART)

func _on_ModList_mod_current_config_changed(mod_id: String, current_config_name: String) -> void:
	var config: ModConfig = ModLoaderConfig.get_config(mod_id, current_config_name)

	if not config:
		_set_info_text(TEXT_MOD_CURRENT_CONFIG_CHANGE_ERROR)

	ModLoaderConfig.set_current_config(config)

func _on_ModLoader_current_config_changed(_config: ModConfig) -> void:
	_update_ui()

func _set_info_text(new_text: String) -> void:
	info_text.text = new_text
	if new_text == TEXT_RESTART:
		restart_button.show()
	else:
		restart_button.hide()
