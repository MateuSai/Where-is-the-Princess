extends Node2D


@onready var ball: RigidBody2D = $RigidBodyWeapon


func _ready() -> void:
	#print(get_node("..").name)
	$PinJoint2D.node_b = "../.."
	ball.get_node("Hitbox").exclude.push_back(get_node(".."))


func _physics_process(_delta: float) -> void:
	ball.apply_central_force(Vector2.DOWN.rotated(ball.position.angle()) * 100)


func hide_and_disable() -> void:
	hide()
	ball.get_node("CollisionShape2D").set_deferred("disabled", true)


func show_and_enable() -> void:
	show()
	ball.get_node("CollisionShape2D").set_deferred("disabled", false)
