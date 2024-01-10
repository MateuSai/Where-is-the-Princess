class_name BombPath extends Path2D


@onready var path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	path_follow.progress_ratio += 1.8 * delta
