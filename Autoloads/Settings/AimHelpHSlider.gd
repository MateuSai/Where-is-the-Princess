extends HSlider


func _ready() -> void:
	value = Settings.aim_help

	drag_ended.connect(func(new_value: float):
		Settings.settings.set_value(Settings.ACCESSIBILITY_SECTION, "aim_help", new_value)
	)
