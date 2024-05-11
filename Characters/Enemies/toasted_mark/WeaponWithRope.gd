class_name WeaponWithRope extends Node2D

var character: Node2D

@export var character_joint: PinJoint2D
@export var weapon_body: RigidBody2D

@onready var hitbox: Hitbox = $"%Hitbox"

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	#print((spear_body.global_position - character.global_position).normalized())
	#spear_body.apply_central_force(Vector2(500, -500))
	weapon_body.apply_central_force((character.global_position - weapon_body.global_position).normalized() * delta * 100000)

func attach(to: NodePath, dir: Vector2) -> void:
	rotation = dir.angle()
	character = get_node(to)
	character_joint.node_b = to
	weapon_body.get_node("Hitbox").exclude.push_back(get_node(to))
	#weapon_body.add_collision_exception_with(get_node(to))
	weapon_body.apply_impulse(dir * 500, Vector2(6, -6))
	#spear_body.set_pos(spear_initial_pos)

func start_pulling() -> void:
	weapon_body.apply_impulse((weapon_body.global_position - character.global_position).normalized() * 50)
	set_physics_process(true)
