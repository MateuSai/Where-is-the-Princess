class_name SpearAndRope extends Node2D


@onready var spear_body: RigidBodyWeapon = $RigidBody2D


func attach(to: NodePath, dir: Vector2) -> void:
	rotation = dir.angle()
	$Rope/PinJoint2D10.node_b = to
	spear_body.add_collision_exception_with(get_node(to))
	spear_body.apply_impulse(dir * 500, Vector2(6, -6))
	#spear_body.set_pos(spear_initial_pos)
