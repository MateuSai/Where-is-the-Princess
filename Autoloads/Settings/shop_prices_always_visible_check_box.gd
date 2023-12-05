extends ButtonWithSound


func _ready() -> void:
	super()

	button_pressed = Settings.shop_prices_always_visible
	toggled.connect(func(button_toggled: bool) -> void:
		Settings.shop_prices_always_visible = button_toggled
	)
