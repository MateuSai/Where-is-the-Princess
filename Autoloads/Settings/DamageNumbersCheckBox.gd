extends ButtonWithSound


func _ready() -> void:
	super()

	button_pressed = Settings.damage_numbers
	toggled.connect(func(button_toggled: bool) -> void:
		Settings.damage_numbers = button_toggled
	)
