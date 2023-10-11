extends Popup

const SETTINGS_PATH: String = "user://settings.cfg"

var settings: ConfigFile = null

var screen_flashes: bool:
	get:
		return settings.get_value("Accessibility", "screen_flashes", true)
var auto_aim: bool:
	get:
		return settings.get_value("Accessibility", "auto_aim", false)
signal auto_aim_changed(new_value: bool)

var MAPPEABLE_ACTIONS: PackedStringArray = PackedStringArray(["ui_attack", "ui_previous_weapon", "ui_next_weapon", "ui_throw_weapon", "ui_weapon_ability", "ui_armor_ability", "ui_minimap"])

@onready var tab_container: TabContainer = $TabContainer


func _init() -> void:
	_load_settings()


func _ready() -> void:
	hide()

#	# Esta wea es para que se generen las traducciones
#	tab_container.get_node("General").name = tr("General")
	popup_hide.connect(_save_settings)

#	for action in MAPPEABLE_ACTIONS:
#		for event in InputMap.action_get_events(action):
#			print(action + ": " + str(event))

	get_tree().root.size_changed.connect(func():
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
	)


func _save_settings() -> void:
	settings.set_value("General", "language", TranslationServer.get_locale())
	settings.set_value("General", "window_mode", DisplayServer.window_get_mode())
	settings.set_value("General", "vsync_mode", DisplayServer.window_get_vsync_mode())
	settings.set_value("General", "fps", Engine.max_fps)

	for action in MAPPEABLE_ACTIONS:
		var saved_keys: Dictionary = {}
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				saved_keys["keyboard_and_mouse"] = {
					type = "key",
					keycode = OS.get_keycode_string(event.keycode)
				}
			elif event is InputEventMouseButton:
				saved_keys["keyboard_and_mouse"] = {
					type = "mouse_button",
					button_index = event.button_index
				}
			elif event is InputEventJoypadButton:
				saved_keys["controller"] = {
					type = "button",
					button_index = event.button_index
				}
			elif event is InputEventJoypadMotion:
				saved_keys["controller"] = {
					type = "motion",
					axis = event.axis
				}
			else:
				push_warning("Unhandled case!!")
		settings.set_value("Input", action, saved_keys)

	settings.set_value("Audio", "master_volume", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	settings.set_value("Audio", "music_volume", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	settings.set_value("Audio", "sounds_volume", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds")))

	settings.save(SETTINGS_PATH)


func _load_settings() -> void:
	settings = ConfigFile.new()
	settings.load(SETTINGS_PATH)

	var language: String = settings.get_value("General", "language", "")
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
	DisplayServer.window_set_mode(settings.get_value("General", "window_mode", DisplayServer.WINDOW_MODE_WINDOWED))
	DisplayServer.window_set_vsync_mode(settings.get_value("General", "vsync_mode", DisplayServer.VSYNC_ADAPTIVE))
	Engine.max_fps = settings.get_value("General", "fps", 60)

	for action in MAPPEABLE_ACTIONS:
		var saved_keys: Dictionary = settings.get_value("Input", action, {})
		if not saved_keys.is_empty():
			InputMap.erase_action(action)
			InputMap.add_action(action)
			if saved_keys["keyboard_and_mouse"].type == "key":
				var event: InputEvent = InputEventKey.new()
				event.keycode = OS.find_keycode_from_string(saved_keys["keyboard_and_mouse"].keycode)
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

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), settings.get_value("Audio", "master_volume", 0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), settings.get_value("Audio", "music_volume", 0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), settings.get_value("Audio", "sounds_volume", 0))


func set_auto_aim(new_value: bool) -> void:
	settings.set_value("Accessibility", "auto_aim", new_value)
	auto_aim_changed.emit(new_value)
