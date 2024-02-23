extends AcidPuddle

@onready var dir: Vector2 = Vector2.RIGHT.rotated(randf_range(0.0, 2*PI))
@onready var initial_position: Vector2 = position


func _process(delta: float) -> void:
	dir = dir.rotated(randf_range(-0.6, 0.6))
	var new_position: Vector2 = position + dir * randf_range(0.6, 1.8) * delta
	new_position = new_position.clamp(initial_position - Vector2(12, 12), initial_position + Vector2(12, 12))
	position = new_position
