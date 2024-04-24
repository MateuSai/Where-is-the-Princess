@tool

class_name ProjectileDetector extends Area2D

@export var radius: int = 32: set = _set_radius

var projectiles_inside: Array[Projectile] = []

var collision_shape: CollisionShape2D
var shape: CircleShape2D

@onready var enemy: Enemy = get_parent()

func _init() -> void:
    collision_layer = 0
    collision_mask = 8 # Projectile

    collision_shape = CollisionShape2D.new()
    add_child(collision_shape)

    shape = CircleShape2D.new()
    collision_shape.shape = shape

    area_entered.connect(_on_projectile_entered)
    area_exited.connect(_on_projectile_exited)

func are_there_projectiles_inside() -> bool:
    return not projectiles_inside.is_empty()

func get_dodge_direction() -> Vector2:
    assert(are_there_projectiles_inside())

    var dodge_dir: Vector2 = Vector2.ZERO

    for projectile: Projectile in projectiles_inside:
        var rot_dif: float = projectile.direction.angle() - (enemy.global_position - projectile.global_position).angle()
        dodge_dir += Vector2.RIGHT.rotated((enemy.global_position - projectile.global_position).angle() + rot_dif)

    return dodge_dir.normalized()

func _on_projectile_entered(projectile: Projectile) -> void:
    projectiles_inside.push_back(projectile)

func _on_projectile_exited(projectile: Projectile) -> void:
    projectiles_inside.erase(projectile)

func _set_radius(new_radius: int) -> void:
    radius = new_radius
    shape.radius = new_radius