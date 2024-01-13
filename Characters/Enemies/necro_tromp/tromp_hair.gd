class_name TrompHair extends Sprite2D

var dir: Vector2 = Vector2.RIGHT.rotated(randf_range(0.0, 2*PI))


func _ready() -> void:
	($VisibleOnScreenNotifier2D as VisibleOnScreenNotifier2D).screen_exited.connect(queue_free)
	if dir.x < 0:
		flip_h = true


func _physics_process(delta: float) -> void:
	position += dir * 35 * delta
