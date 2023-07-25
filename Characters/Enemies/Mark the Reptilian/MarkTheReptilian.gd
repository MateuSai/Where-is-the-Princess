extends Enemy


@onready var weapon: Node2D = $Weapon
@onready var weapon_body: RigidBodyWeapon = $Weapon/RigidBody2D
@onready var rope: Node2D = $Weapon/Rope
@onready var weapon_joint: PinJoint2D = $Weapon/Rope/PinJoint2D


func _ready() -> void:
	#weapon_body.process_mode = Node.PROCESS_MODE_DISABLED
	weapon_body.position = Vector2.DOWN * 8
	weapon_body.can_move = false
	rope.hide()



func point_to_player() -> void:
	weapon.rotation = (player.position - global_position).angle()


func attack() -> void:
	weapon.rotation = (player.position - global_position).angle()
	rope.show()
	#$Weapon.rotation = (player.position - global_position).angle() - PI/2
	weapon_body.can_move = true
	#weapon_joint.node_a = weapon_joint.get_path_to(weapon_body)
	weapon_body.apply_impulse((player.position - weapon.global_position).normalized() * 800)


func pull_back_weapon() -> void:
	#weapon_body.linear_velocity = Vector2.ZERO
	#weapon_body.freeze = true
	#rope.hide()
	#weapon_joint.node_a = ""
	weapon_body.can_move = false
	weapon_body.set_pos(global_position + Vector2.DOWN * 8)
	#weapon_body.position = Vector2.DOWN * 8
	#weapon_body.global_position = global_position + Vector2.DOWN * 8
