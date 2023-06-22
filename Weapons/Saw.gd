class_name Saw extends Projectile


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotation += 15 * delta
	super(delta)
