class_name BombParabola extends Path2D


func _ready() -> void:
	set_physics_process(false)


func start(dir: Vector2) -> void:
	if dir.x >= 0:
		rotation = dir.angle()
	else:
		scale.x = -1
		rotation = dir.angle() - PI
