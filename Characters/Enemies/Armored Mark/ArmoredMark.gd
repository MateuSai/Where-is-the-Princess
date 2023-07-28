class_name ArmoredMark extends Enemy


var ball_and_chain: SpearAndRope

signal ball_picked_up()


func attack() -> void:
	return
#	pick_up_spear_area_collision_shape.set_deferred("disabled", true)
#
#	await get_tree().create_timer(randf_range(0.2, 0.8), false).timeout
#
#	spear_sprite.hide()
#
#	spear_and_rope = load("res://Characters/Enemies/Mark the Reptilian/SpearAndRope.tscn").instantiate()
#	get_tree().current_scene.add_child(spear_and_rope)
#	spear_and_rope.position = global_position
#	spear_and_rope.attach(get_path(), (player.position - global_position).normalized())
#	#weapon.rotation = (player.position - global_position).angle()
#	#rope.show()
#	#$Weapon.rotation = (player.position - global_position).angle() - PI/2
#	#weapon_body.can_move = true
#	#weapon_joint.node_a = weapon_joint.get_path_to(weapon_body)
#	#weapon_body.apply_impulse((player.position - weapon.global_position).normalized() * 1500)
#
#	await get_tree().create_timer(randf_range(0.8, 1.4), false).timeout
#
#	_pull_back_weapon()
