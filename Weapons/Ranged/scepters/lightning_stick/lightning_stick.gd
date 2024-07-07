class_name LightningStick extends Scepter


func _spawn_projectile(angle: float = 0.0, amount: int = 1, _rotate_to_dir: bool = true) -> Array[Projectile]:
	var projectiles: Array[Projectile] = super(angle, amount, false)

	for projectile: Projectile in projectiles:
		var homing_component: HomingComponent = load("res://Components/character_detector/homing_component.tscn").instantiate()
		homing_component.homing_degree = 0.08
		projectile.add_child(homing_component)

	return projectiles


func _spawn_lightning() -> void:
	#staff_animation_player.play("lighting_attack")
	#await staff_animation_player.animation_finished
	#if staff_animation_player.assigned_animation == "RESET": # this means we cancelled the attack
		#return
	#can_move = false

	var lightning: LightningAreaAttack = load("res://Weapons/Ranged/scepters/lightning_stick/LightningAreaAttack.tscn").instantiate()
	lightning.position = global_position
	for body: PhysicsBody2D in (get_parent().get_parent() as Character).get_exclude_bodies():
		lightning.exclude.push_back(body)
	get_tree().current_scene.add_child(lightning)
	lightning.attack(Vector2.RIGHT.rotated(rotation))
	Globals.player.camera.flash()
#	var lightning_line: LightningLine2D = LightningLine2D.new()
#	get_tree().current_scene.add_child(lightning_line)
#	lightning_line.lightning(player.position, global_position)
	#await lightning.tree_exiting

	#if is_instance_valid(staff):
	#if is_instance_valid(staff_animation_player):
		#staff_animation_player.play("after_lightning_attack")
		#await staff_animation_player.animation_finished
	#can_move = true
#
	#return []
