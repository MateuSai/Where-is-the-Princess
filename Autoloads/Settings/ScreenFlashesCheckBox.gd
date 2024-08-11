extends ButtonWithSound


func _ready() -> void:
	super()

	button_pressed = Settings.screen_flashes
	toggled.connect(func(button_toggled: bool) -> void:
		Settings.settings.set_value(Settings.ACCESSIBILITY_SECTION, "screen_flashes", button_toggled)
	)
