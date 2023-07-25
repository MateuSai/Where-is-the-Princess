class_name RigidBodyWeapon extends RigidBody2D


var change_position: bool = false
var new_pos: Vector2

var can_move: bool = true


func _ready() -> void:
	add_collision_exception_with(owner)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not can_move:
		$Sprite2D.rotation = (owner.player.position - owner.global_position).angle()
		$CollisionShape2D.rotation = (owner.player.position - owner.global_position).angle() - PI/2
		state.linear_velocity = Vector2.ZERO
		state.transform.origin = owner.global_position + (Vector2.RIGHT * 8).rotated((owner.player.position - owner.global_position).angle())

	if change_position:
		state.transform.origin = new_pos
		state.linear_velocity = Vector2.ZERO
		change_position = false


@warning_ignore("shadowed_variable")
func set_pos(new_pos: Vector2) -> void:
	self.new_pos = new_pos
	change_position = true
