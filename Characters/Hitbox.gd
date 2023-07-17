class_name Hitbox extends Area2D

@export var damage: int = 1
var knockback_direction: Vector2 = Vector2.ZERO
@export var knockback_force: int = 300

var body_inside: bool = false

signal collided_with_something(body: Node2D)

@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var timer: Timer = Timer.new()

enum CollisionMaterial {
	FLESH,
	STONE,
}


func _ready() -> void:
	assert(collision_shape != null)
	timer.wait_time = 1
	add_child(timer)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	body_inside = true
	timer.start()
	while body_inside:
		_collide(body)
		await timer.timeout


func _on_body_exited(_body: Node2D) -> void:
	body_inside = false
	timer.stop()


func _collide(body: Node2D, dam: int = damage) -> void:
	collided_with_something.emit(body)
	if body == null or not body.has_node("LifeComponent"):
		queue_free()
	else:
		body.get_node("LifeComponent").take_damage(dam, knockback_direction, knockback_force)
