class_name ArmoredMark extends Enemy


var long_chain_and_iron_ball: WeaponWithRope
@onready var short_chain_and_iron_ball: Node2D = $ShortChainAndIronBall

signal ball_picked_up()


@onready var pick_up_ball_area_collision_shape: CollisionShape2D = $PickUpBallArea/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var pull_back_timer: Timer = $PullBackTimer


func _ready() -> void:
	super()

	attack_timer.timeout.connect(func() -> void:
		_throw()
		pull_back_timer.start(randf_range(0.8, 1.4))
	)
	pull_back_timer.timeout.connect(_pull_back_weapon)


func attack() -> void:
	pick_up_ball_area_collision_shape.set_deferred("disabled", true)

	attack_timer.start(randf_range(0.2, 0.8))

#	short_chain_and_iron_ball.hide_and_disable()
#
#	long_chain_and_iron_ball = load("res://Characters/Enemies/ArmoredMark/LongChainAndIronBall.tscn").instantiate()
#	get_tree().current_scene.add_child(long_chain_and_iron_ball)
#	long_chain_and_iron_ball.position = global_position
#	long_chain_and_iron_ball.attach(get_path(), (player.position - global_position).normalized())
	# weapon.rotation = (player.position - global_position).angle()
	#rope.show()
	#$Weapon.rotation = (player.position - global_position).angle() - PI/2
	#weapon_body.can_move = true
	#weapon_joint.node_a = weapon_joint.get_path_to(weapon_body)
	#weapon_body.apply_impulse((player.position - weapon.global_position).normalized() * 1500)

#	await get_tree().create_timer(randf_range(0.8, 1.4), false).timeout
#
#	_pull_back_weapon()


func _throw() -> void:
	short_chain_and_iron_ball.hide_and_disable()

	long_chain_and_iron_ball = load("res://Characters/Enemies/ArmoredMark/LongChainAndIronBall.tscn").instantiate()
	get_tree().current_scene.add_child(long_chain_and_iron_ball)
	long_chain_and_iron_ball.position = global_position
	long_chain_and_iron_ball.attach(get_path(), (player.position - global_position).normalized())


func _pull_back_weapon() -> void:
	pick_up_ball_area_collision_shape.set_deferred("disabled", false)
	long_chain_and_iron_ball.start_pulling()


func _on_pick_up_ball_area_body_entered(body: Node2D) -> void:
	if is_instance_valid(long_chain_and_iron_ball) and body == long_chain_and_iron_ball.weapon_body:
		long_chain_and_iron_ball.queue_free()
		short_chain_and_iron_ball.show_and_enable()
		ball_picked_up.emit()


func _add_short_chain_and_ball() -> void:
	short_chain_and_iron_ball = load("res://Characters/Enemies/Armored Mark/ShortChainAndIronBall.tscn").instantiate()
	short_chain_and_iron_ball.position = global_position + Vector2.UP * 8
	get_tree().current_scene.add_child(short_chain_and_iron_ball)


func _on_died() -> void:
	attack_timer.stop()
	pull_back_timer.stop()
	if is_instance_valid(long_chain_and_iron_ball):
		long_chain_and_iron_ball.queue_free()

	super()
