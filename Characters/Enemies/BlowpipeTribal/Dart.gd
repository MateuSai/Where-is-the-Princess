class_name Dart extends Projectile

func _collide(body: Node2D, dam: int = damage) -> void:
	if body is Player:
		body.enable_mirage()

	super(body, dam)
