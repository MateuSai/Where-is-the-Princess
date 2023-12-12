extends Popup

const SETTINGS_PATH: String = "user://settings.cfg"

const GENERAL_SECTION: String = "General"
const INPUT_SECTION: String = "Input"
const AUDIO_SECTION: String = "Audio"
const ACCESSIBILITY_SECTION: String = "Accessibility"

var settings: ConfigFile = null

var damage_numbers: bool:
	get:
		return settings.get_value(GENERAL_SECTION, "damage_numbers", true)
	set(new_value):
		settings.set_value(GENERAL_SECTION, "damage_numbers", new_value)
		damage_numbers_changed.emit(new_value)
signal damage_numbers_changed(new_value: bool)
var shop_prices_always_visible: bool:
	get:
		return settings.get_value(GENERAL_SECTION, "shop_prices_always_visible", true)
	set(new_value):
		settings.set_value(GENERAL_SECTION, "shop_prices_always_visible", new_value)
		shop_prices_always_visible_changed.emit(new_value)
signal shop_prices_always_visible_changed(new_value: bool)

var screen_flashes: bool:
	get:
		return settings.get_value(ACCESSIBILITY_SECTION, "screen_flashes", true)
var auto_aim: bool:
	get:
		return settings.get_value(ACCESSIBILITY_SECTION, "auto_aim", false)
signal auto_aim_changed(new_value: bool)
var aim_help: float:
	get:
		return settings.get_value(ACCESSIBILITY_SECTION, "aim_help", 0.0)
	set(new_value):
		set_aim_help(new_value)
signal aim_help_changed(new_value: float)

var MAPPEABLE_ACTIONS: PackedStringArray = PackedStringArray(["ui_attack", "ui_previous_weapon", "ui_next_weapon", "ui_throw_weapon", "ui_weapon_ability", "ui_armor_ability", "ui_minimap", "ui_interact"])

@onready var tab_container: TabContainer = $TabContainer


func _init() -> void:
	_load_settings()


func _ready() -> void:
	hide()

#	# Esta wea es para que se generen las traducciones
#	tab_container.get_node(GENERAL_SECTION).name = tr(GENERAL_SECTION)
	popup_hide.connect(_save_settings)

#	for action in MAPPEABLE_ACTIONS:
#		for event in InputMap.action_get_events(action):
#			print(action + ": " + str(event))

	get_tree().root.size_changed.connect(func() -> void:
		if visible:
#			var screen_size: Vector2 = get_tree().get_root().size
#			var set_width: float = ProjectSettings.get("display/window/size/viewport_width")
#			var set_height: float = ProjectSettings.get("display/window/size/viewport_height")
#			var real_size: Vector2 = Vector2(size) * screen_size / Vector2(set_width, set_height)
#			position = Vector2(get_tree().root.size)/2 - real_size/2
#			print(Vector2(get_tree().root.size)/2 - real_size/2)
			var t: Transform2D = get_tree().root.get_final_transform()
			var scale: Vector2 = t.get_scale()
			position = -t.origin / scale + Vector2(get_tree().root.size) / scale / 2 - Vector2(size) / 2

		# To save window size
		settings.set_value(GENERAL_SECTION, "window_size", DisplayServer.window_get_size())
		settings.save(SETTINGS_PATH)
	)


func _save_settings() -> void:
	settings.set_value(GENERAL_SECTION, "language", TranslationServer.get_locale())
	settings.set_value(GENERAL_SECTION, "window_mode", DisplayServer.window_get_mode() if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_WINDOWED)
	settings.set_value(GENERAL_SECTION, "vsync_mode", DisplayServer.window_get_vsync_mode())
	settings.set_value(GENERAL_SECTION, "fps", Engine.max_fps)

	for action: String in MAPPEABLE_ACTIONS:
		var saved_keys: Dictionary = {}
		for event: InputEvent in InputMap.action_get_events(action):
			if event is InputEventKey:
				saved_keys["keyboard_and_mouse"] = {
					type = "key",
					keycode = OS.get_keycode_string((event as InputEventKey).keycode)
				}
			elif event is InputEventMouseButton:
				saved_keys["keyboard_and_mouse"] = {
					type = "mouse_button",
					button_index = (event as InputEventMouseButton).button_index
				}
			elif event is InputEventJoypadButton:
				saved_keys["controller"] = {
					type = "button",
					button_index = (event as InputEventJoypadButton).button_index
				}
			elif event is InputEventJoypadMotion:
				saved_keys["controller"] = {
					type = "motion",
					axis = (event as InputEventJoypadMotion).axis
				}
			else:
				push_warning("Unhandled case!!")
		settings.set_value(INPUT_SECTION, action, saved_keys)

	settings.set_value(AUDIO_SECTION, "master_volume", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	settings.set_value(AUDIO_SECTION, "music_volume", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	settings.set_value(AUDIO_SECTION, "sounds_volume", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds")))

	settings.save(SETTINGS_PATH)


func _load_settings() -> void:
	settings = ConfigFile.new()
	settings.load(SETTINGS_PATH)

	var language: String = settings.get_value(GENERAL_SECTION, "language", "")
	if not language.is_empty():
		TranslationServer.set_locale(language)
	else:
		var os_locale: String = OS.get_locale()
		if os_locale.begins_with("es"):
			TranslationServer.set_locale("es")
		elif os_locale.begins_with("ca"):
			TranslationServer.set_locale("ca")
		else:
			TranslationServer.set_locale("en")
	DisplayServer.window_set_mode(settings.get_value(GENERAL_SECTION, "window_mode", DisplayServer.WINDOW_MODE_WINDOWED) as DisplayServer.WindowMode)
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		var saved_window_size: Vector2 = settings.get_value(GENERAL_SECTION, "window_size", Vector2(ProjectSettings.get_setting("display/window/size/window_width_override") as float, ProjectSettings.get_setting("display/window/size/window_height_override") as float))
		DisplayServer.window_set_size(saved_window_size)
	DisplayServer.window_set_vsync_mode(settings.get_value(GENERAL_SECTION, "vsync_mode", DisplayServer.VSYNC_ADAPTIVE) as DisplayServer.VSyncMode)
	Engine.max_fps = settings.get_value(GENERAL_SECTION, "fps", 60)

	for action: String in MAPPEABLE_ACTIONS:
		var saved_keys: Dictionary = settings.get_value(INPUT_SECTION, action, {})
		if not saved_keys.is_empty():
			InputMap.erase_action(action)
			InputMap.add_action(action)
			if saved_keys["keyboard_and_mouse"].type == "key":
				var event: InputEventKey = InputEventKey.new()
				var key_string: String = saved_keys["keyboard_and_mouse"].keycode
				event.keycode = OS.find_keycode_from_string(key_string)
				InputMap.action_add_event(action, event)
			elif saved_keys["keyboard_and_mouse"].type == "mouse_button":
				var event: InputEventMouseButton = InputEventMouseButton.new()
				event.button_index = saved_keys["keyboard_and_mouse"].button_index
				InputMap.action_add_event(action, event)
			else:
				push_warning("Unhandled case!!")
			if saved_keys["controller"].type == "button":
				var event: InputEventJoypadButton = InputEventJoypadButton.new()
				event.button_index = saved_keys["controller"].button_index
				InputMap.action_add_event(action, event)
			elif saved_keys["controller"].type == "motion":
				var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
				event.axis = saved_keys["controller"].axis
				InputMap.action_add_event(action, event)
			else:
				push_warning("Unhandled case!!")

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), settings.get_value(AUDIO_SECTION, "master_volume", 0) as float)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), settings.get_value(AUDIO_SECTION, "music_volume", 0) as float)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), settings.get_value(AUDIO_SECTION, "sounds_volume", 0) as float)


func set_auto_aim(new_value: bool) -> void:
	settings.set_value(ACCESSIBILITY_SECTION, "auto_aim", new_value)
	auto_aim_changed.emit(new_value)


func set_aim_help(new_value: float) -> void:
	settings.set_value(ACCESSIBILITY_SECTION, "aim_help", new_value)
	aim_help_changed.emit(new_value)
