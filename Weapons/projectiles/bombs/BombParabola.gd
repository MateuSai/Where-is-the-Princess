class_name BombParabola extends BombPath


func start(dir: Vector2, distance: float) -> void:
	if dir.x >= 0:
		rotation = dir.angle()
	else:
		scale.x = -1
		rotation = dir.angle() - PI

	curve.set_point_position(2, Vector2(distance, 0))

	set_physics_process(true)
