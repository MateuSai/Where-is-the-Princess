class_name MagicBouncingProjectile extends Projectile


func initialize_magic_bouncing_projectile(frame: int, small: bool = false) -> void:
	sprite.frame = frame
	if small:
		sprite.texture = load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Tromp the necromancer/Energy_attack_small_anim_10x10.png")
		$CollisionShape2D.shape.radius = 3


func destroy() -> void:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(position - direction * 4, position + direction * 16, collision_mask)
	var result: Dictionary = space_state.intersect_ray(query)

	if not result.is_empty():
		var normal: Vector2 = result.normal
		var small_magic_bouncing_projectile_scene: PackedScene = load("res://Weapons/projectiles/magic_bouncing_projectile/magic_bouncing_projectile.tscn")
		for i: int in 3:
			var dir: Vector2 = normal.rotated(randf_range(-PI/2, PI/2))
			for frame_num: int in 6:
				var small_magic_bouncing_projectile: MagicBouncingProjectile = small_magic_bouncing_projectile_scene.instantiate()
				get_parent().add_child(small_magic_bouncing_projectile)
				small_magic_bouncing_projectile.launch(global_position, dir, speed * 1.3, true)
				small_magic_bouncing_projectile.initialize_magic_bouncing_projectile(frame_num, true)

	else: # For some reason the projectile has not found the body which it collided with. We don't count it as a bounce
		push_error("For some reason the projectile has not found the body which it collided with")
		bounces_remaining += 1

	super()
