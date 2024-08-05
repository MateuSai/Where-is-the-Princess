extends ButtonWithSound


func _ready() -> void:
	super()

	button_pressed = !Settings.controller_vibration
	toggled.connect(func(button_toggled: bool) -> void:
		Settings.set_controller_vibration(!button_toggled)
	)
