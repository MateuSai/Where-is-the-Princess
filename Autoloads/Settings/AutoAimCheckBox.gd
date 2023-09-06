extends CheckBox


func _ready() -> void:
	button_pressed = Settings.auto_aim
	toggled.connect(func(button_toggled: bool):
		Settings.set_auto_aim(button_toggled)
	)
