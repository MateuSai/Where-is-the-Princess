extends Enemy


var spear_and_rope: WeaponWithRope

signal spear_picked_up()

@onready var spear_pivot: Node2D = $SpearPivot
@onready var spear_sprite: Sprite2D = spear_pivot.get_node("SpearSprite")
@onready var pick_up_spear_area_collision_shape: CollisionShape2D = $PickUpSpearArea/CollisionShape2D
#@onready var weapon: Node2D = $Weapon
#@onready var weapon_body: RigidBodyWeapon = $Weapon/RigidBody2D
#@onready var rope: Node2D = $Weapon/Rope
#@onready var weapon_joint: PinJoint2D = $Weapon/Rope/PinJoint2D


func _ready() -> void:
	super()
	#weapon_body.process_mode = Node.PROCESS_MODE_DISABLED
#	weapon_body.position = Vector2.DOWN * 8
#	weapon_body.can_move = false
#	rope.hide()



func point_to_player() -> void:
	var vector_to_target: Vector2 = (player.position - global_position)
	spear_pivot.rotation = vector_to_target.angle()
#	if vector_to_target.x > 0:
#		spear_pivot.scale.x = 1
#	else:
#		spear_pivot.scale.x = -1

	if vector_to_target.x < 0:
		spear_pivot.scale.y = -1
	else:
		spear_pivot.scale.y = 1

	#weapon.rotation = (player.position - global_position).angle()


func attack() -> void:
	pick_up_spear_area_collision_shape.set_deferred("disabled", true)

	await get_tree().create_timer(randf_range(0.2, 0.8), false).timeout

	spear_sprite.hide()

	spear_and_rope = load("res://Characters/Enemies/MarkTheReptilian/SpearAndRope.tscn").instantiate()
	get_tree().current_scene.add_child(spear_and_rope)
	spear_and_rope.position = global_position
	var vector_to_player: Vector2 = (player.position - global_position)
	if vector_to_player.x < 0:
		spear_and_rope.scale.y = -1
	spear_and_rope.attach(get_path(), vector_to_player.normalized())
	#weapon.rotation = (player.position - global_position).angle()
	#rope.show()
	#$Weapon.rotation = (player.position - global_position).angle() - PI/2
	#weapon_body.can_move = true
	#weapon_joint.node_a = weapon_joint.get_path_to(weapon_body)
	#weapon_body.apply_impulse((player.position - weapon.global_position).normalized() * 1500)

	await get_tree().create_timer(randf_range(0.8, 1.4), false).timeout

	_pull_back_weapon()


func _pull_back_weapon() -> void:
	pick_up_spear_area_collision_shape.set_deferred("disabled", false)
	spear_and_rope.start_pulling()
#	if is_instance_valid(spear_and_rope):
#		spear_and_rope.queue_free()
	#weapon_body.linear_velocity = Vector2.ZERO
	#weapon_body.freeze = true
	#rope.hide()
	#weapon_joint.node_a = ""
	#weapon_body.can_move = false
	#weapon_body.set_pos(global_position + Vector2.DOWN * 8)
	#weapon_body.position = Vector2.DOWN * 8
	#weapon_body.global_position = global_position + Vector2.DOWN * 8


func _on_pick_up_spear_area_body_entered(body: Node2D) -> void:
	if is_instance_valid(spear_and_rope) and body == spear_and_rope.weapon_body:
		spear_and_rope.queue_free()
		spear_sprite.show()
		spear_picked_up.emit()
