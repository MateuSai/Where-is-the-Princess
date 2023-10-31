class_name Projectile extends Hitbox

const HOMING_COMPONENT_SCENE: PackedScene = preload("res://Components/homing_component.tscn")

var direction: Vector2 = Vector2.ZERO
var speed: int = 0

@export var random_rotate: bool = false
var rot_dir: int = [-1, 1][randi() % 2]

@export var can_be_destroyed: bool = true


@warning_ignore("shadowed_variable")
func launch(initial_position: Vector2, dir: Vector2, speed: int, rotate_to_dir: bool = false, homing_degree: float = 0.0) -> void:
	position = initial_position
	direction = dir
	knockback_direction = dir
	self.speed = speed

	if rotate_to_dir:
		rotation = dir.angle()

	if homing_degree > 0.0:
		var homing_component: HomingComponent = HOMING_COMPONENT_SCENE.instantiate()
		homing_component.homing_degree = homing_degree
		add_child(homing_component)

	#rotation += dir.angle() + PI/4


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if random_rotate:
		rotation += rot_dir * delta


func _collide(node: Node2D, _dam: int = damage) -> void:
	collided_with_something.emit(node)

	if node.get("life_component") != null:
		node.life_component.take_damage(damage, knockback_direction, knockback_force)
	destroy()


func destroy() -> void:
	queue_free()
