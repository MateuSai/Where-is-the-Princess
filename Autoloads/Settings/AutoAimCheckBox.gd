extends CheckBox


func _ready() -> void:
	button_pressed = Settings.auto_aim
	toggled.connect(func(button_toggled: bool):
		Settings.settings.set_value("Accessibility", "auto_aim", button_toggled)
	)
