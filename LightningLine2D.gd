class_name LightningLine2D extends Line2D

func _init() -> void:
	width = 4


func lightning(to: Vector2, from: Vector2) -> void:
	points = PackedVector2Array([to, from])
	await create_tween().tween_property(self, "modulate:a", 0, 0.5).finished
	queue_free()
