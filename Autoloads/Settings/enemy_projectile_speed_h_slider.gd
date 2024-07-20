extends HSlider

func _ready() -> void:
	value = Settings.enemy_projectile_speed

	drag_ended.connect(func(_has_value_changed: bool) -> void:
		Settings.set_enemy_projectile_speed(value)
	)
