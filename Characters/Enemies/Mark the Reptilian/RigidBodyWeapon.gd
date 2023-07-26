class_name RigidBodyWeapon extends RigidBody2D


var change_position: bool = false
var new_pos: Vector2


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#super(state)
	if change_position:
		state.transform.origin = new_pos
		state.linear_velocity = Vector2.ZERO
		change_position = false


@warning_ignore("shadowed_variable")
func set_pos(new_pos: Vector2) -> void:
	self.new_pos = new_pos
	change_position = true
