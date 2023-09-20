class_name BombParabola extends Path2D

@onready var path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	set_physics_process(false)


func start(dir: Vector2, distance: float) -> void:
	if dir.x >= 0:
		rotation = dir.angle()
	else:
		scale.x = -1
		rotation = dir.angle() - PI

	curve.set_point_position(2, Vector2(distance, 0))

	set_physics_process(true)


func _physics_process(delta: float) -> void:
	path_follow.progress_ratio += 1.8 * delta
