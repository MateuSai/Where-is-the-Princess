extends Sprite2D

var direction: Vector2 = Vector2.ZERO
var speed: int = 0


@warning_ignore("shadowed_variable")
func launch(initial_position: Vector2, dir: Vector2, speed: int) -> void:
	position = initial_position
	direction = dir
	self.speed = speed


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
