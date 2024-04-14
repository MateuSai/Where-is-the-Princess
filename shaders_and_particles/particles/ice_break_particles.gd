class_name IceBreakParticles extends GPUParticles2D

func _init() -> void:
    one_shot = true
    emitting = true
    finished.connect(queue_free)