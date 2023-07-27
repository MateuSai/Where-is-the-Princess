class_name SpearAndRope extends Node2D

var character: Character

@onready var spear_body: RigidBodyWeapon = $RigidBody2D


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	print((spear_body.global_position - character.global_position).normalized())
	#spear_body.apply_central_force(Vector2(500, -500))
	spear_body.apply_central_force((character.global_position - spear_body.global_position).normalized() * delta * 100000)


func attach(to: NodePath, dir: Vector2) -> void:
	rotation = dir.angle()
	character = get_node(to)
	$Rope/PinJoint2D10.node_b = to
	#spear_body.add_collision_exception_with(get_node(to))
	spear_body.apply_impulse(dir * 500, Vector2(6, -6))
	#spear_body.set_pos(spear_initial_pos)


func start_pulling() -> void:
	spear_body.apply_impulse((spear_body.global_position - character.global_position).normalized() * 50)
	set_physics_process(true)
