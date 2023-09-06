extends CheckBox


func _ready() -> void:
	button_pressed = Settings.screen_flashes
	toggled.connect(func(button_toggled: bool):
		Settings.settings.set_value("Accessibility", "screen_flashes", button_toggled)
	)
