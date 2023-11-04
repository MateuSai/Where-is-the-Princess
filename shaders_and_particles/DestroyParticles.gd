extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	one_shot = true
	emitting = true
	await get_tree().create_timer(lifetime * 1.5).timeout
	queue_free()
