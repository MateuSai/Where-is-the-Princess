@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/boss_druid/rock.png")
class_name Projectile extends Hitbox

const HOMING_COMPONENT_SCENE: PackedScene = preload("res://Components/homing_component.tscn")

var direction: Vector2 = Vector2.ZERO:
	set(new_dir):
		direction = new_dir
		if rotate_to_dir and not random_rotate:
			rotation = direction.angle()
var speed: int = 0
var rotate_to_dir: bool = false

@export var random_rotate: bool = false
var rot_dir: int = [-1, 1][randi() % 2]

var piercing: int = 0
var bodies_pierced: int = 0

var bounces_remaining: int = 0

@export var can_be_destroyed: bool = true


@warning_ignore("shadowed_variable")
func launch(initial_position: Vector2, dir: Vector2, speed: int, rotate_to_dir: bool = false) -> void:
	position = initial_position
	knockback_direction = dir
	self.speed = speed
	self.rotate_to_dir = rotate_to_dir
	self.direction = dir

#	if rotate_to_dir:
#		rotation = dir.angle()

	#rotation += dir.angle() + PI/4


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if random_rotate:
		rotation += rot_dir * delta


func _collide(node: Node2D, _dam: int = damage) -> void:
	collided_with_something.emit(node)

	if node.get("life_component") != null:
		node.life_component.take_damage(damage, knockback_direction, knockback_force, weapon)
		if bodies_pierced >= piercing:
			destroy()
		else:
			bodies_pierced += 1
	else:
		if bounces_remaining > 0:
			bounces_remaining -= 1
			_bounce()
		else:
			destroy()


func destroy() -> void:
	queue_free()


func _bounce() -> void:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(position - direction * 4, position + direction * 16, collision_mask)
	var result: Dictionary = space_state.intersect_ray(query)

	if not result.is_empty():
		direction = direction.bounce(result.normal)
	else: # For some reason the projectile has not found the body which it collided with. We don't count it as a bounce
		push_error("For some reason the projectile has not found the body which it collided with")
		bounces_remaining += 1
