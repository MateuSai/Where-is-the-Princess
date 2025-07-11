@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/boss_druid/rock.png")
class_name Projectile extends Hitbox

const HOMING_COMPONENT_SCENE: PackedScene = preload ("res://Components/character_detector/homing_component.tscn")

var direction: Vector2 = Vector2.ZERO:
	set(new_dir):
		direction = new_dir
		if rotate_to_dir and not random_rotate:
			for child: Node in get_children():
				if child is GPUParticles2D:
					#print_debug(rad_to_deg(direction.angle()) * -1)
					((child as GPUParticles2D).process_material as ParticleProcessMaterial).angle_min = rad_to_deg(direction.angle()) * - 1
					((child as GPUParticles2D).process_material as ParticleProcessMaterial).angle_max = rad_to_deg(direction.angle()) * - 1
				elif child is Node2D:
					child.rotation = direction.angle()
var speed: int = 0
var rotate_to_dir: bool = false

@export var random_rotate: bool = false
var rot_dir: int = [- 1, 1][randi() % 2]

var piercing: int = 0
var bodies_pierced: int = 0

signal destroyed()

var bounces_remaining: int = 0

@export var can_be_destroyed: bool = true

var height: float: get = _get_height

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	super()

	add_to_group("projectiles")

	collision_shape.disabled = true

@warning_ignore("shadowed_variable")
func launch(initial_position: Vector2, dir: Vector2, speed: int, rotate_to_dir: bool=false) -> void:
	position = initial_position
	knockback_direction = dir
	self.speed = speed
	self.rotate_to_dir = rotate_to_dir
	self.direction = dir

	bounces_remaining += Globals.global_stats.projectiles_initial_extra_bounce_charges

	collision_shape.disabled = false

#	if rotate_to_dir:
#		rotation = dir.angle()

	#rotation += dir.angle() + PI/4

func _physics_process(delta: float) -> void:
	var speed_to_use: int = speed if damage_dealer_id == "player" else round(speed * Globals.global_stats.non_player_projectile_speed_multiplier)
	position += direction * speed_to_use * delta
	if random_rotate:
		rotation += rot_dir * delta

func _collide(node: Node2D, dam: int=damage) -> void:
	#Log.debug(name + " collided with: " + node.name)

	collided_with_something.emit(node)

	if damage_dealer is Player:
		dam *= (damage_dealer as Player).damage_multiplier

	if node.get("life_component") != null:
		@warning_ignore("unsafe_property_access")
		var life_component: LifeComponent = node.life_component
		life_component.take_damage(dam, knockback_direction, knockback_force, weapon if is_instance_valid(weapon) else null, damage_dealer, damage_dealer_id, true)
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
	destroyed.emit()

	queue_free()

func _bounce() -> void:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(position - direction * 4, position + direction * 16, collision_mask)
	var result: Dictionary = space_state.intersect_ray(query)

	if not result.is_empty():
		var normal: Vector2 = result.normal
		direction = direction.bounce(normal)
	else: # For some reason the projectile has not found the body which it collided with. We don't count it as a bounce
		push_error("For some reason the projectile has not found the body which it collided with")
		bounces_remaining += 1

func get_direction_to(node: Node2D) -> Vector2:
	return (node.global_position - global_position + Vector2.DOWN * height).normalized()

func _get_height() -> float:
	return - sprite.position.y
