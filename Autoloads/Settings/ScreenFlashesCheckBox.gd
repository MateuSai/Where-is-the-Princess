extends ButtonWithSound


func _ready() -> void:
	super()

	button_pressed = Settings.screen_flashes
	toggled.connect(func(button_toggled: bool):
		Settings.settings.set_value("Accessibility", "screen_flashes", button_toggled)
	)
