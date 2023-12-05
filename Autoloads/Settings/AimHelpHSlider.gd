extends HSlider


func _ready() -> void:
	value = Settings.aim_help

	drag_ended.connect(func(_has_value_changed: bool) -> void:
		Settings.set_aim_help(value)
	)
