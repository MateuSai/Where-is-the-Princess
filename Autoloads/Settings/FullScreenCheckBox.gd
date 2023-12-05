extends ButtonWithSound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

	button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	toggled.connect(func(button_toggled: bool) -> void:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if button_toggled else DisplayServer.WINDOW_MODE_WINDOWED)
	)
