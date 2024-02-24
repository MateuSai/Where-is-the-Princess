extends AcidPuddle

var rot_dir: int = [-1, 1][randi() % 2]
var rot_speed: float = randf_range(0.05, 0.2)

@onready var dir: Vector2 = Vector2.RIGHT.rotated(randf_range(0.0, 2*PI))
@onready var initial_position: Vector2 = position


func _process(delta: float) -> void:
	rotation += rot_dir * rot_speed * delta

	dir = dir.rotated(randf_range(-0.6, 0.6))
	var new_position: Vector2 = position + dir * randf_range(0.4, 1.2) * delta
	new_position = new_position.clamp(initial_position - Vector2(12, 12), initial_position + Vector2(12, 12))
	position = new_position
