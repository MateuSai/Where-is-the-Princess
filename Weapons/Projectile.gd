class_name Projectile extends Hitbox

var direction: Vector2 = Vector2.ZERO
var knife_speed: int = 0

@export var random_rotate: bool = false
var rot_dir: int = [-1, 1][randi() % 2]


func launch(initial_position: Vector2, dir: Vector2, speed: int) -> void:
	position = initial_position
	direction = dir
	knockback_direction = dir
	knife_speed = speed

	#rotation += dir.angle() + PI/4


func _physics_process(delta: float) -> void:
	position += direction * knife_speed * delta
	if random_rotate:
		rotation += rot_dir * delta


func _collide(body: Node2D, _dam: int = damage) -> void:
	if body.get("life_component") != null:
		body.life_component.take_damage(damage, knockback_direction, knockback_force)
	queue_free()
