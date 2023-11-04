class_name Slime extends Enemy


func _ready() -> void:
	super()

	target_random_near_position()


func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		target_random_near_position()
	else:
		path_timer.stop()
		mov_direction = Vector2.ZERO
