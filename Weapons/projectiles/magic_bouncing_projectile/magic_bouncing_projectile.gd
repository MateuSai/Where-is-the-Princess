class_name MagicBouncingProjectile extends Projectile

var small: bool = false


@warning_ignore("shadowed_variable")
func initialize_magic_bouncing_projectile(small: bool = false) -> void:
	self.small = small
	if small:
		sprite.texture = load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Tromp the necromancer/Energy_attack_small_anim_10x10.png")
		$CollisionShape2D.shape.radius = 3
		($GPUParticles2D as GPUParticles2D).texture = load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Tromp the necromancer/Energy_attack_small_anim_10x10.png")


func destroy() -> void:
	#if not small:
		#var small_magic_bouncing_projectile_scene: PackedScene = load("res://Weapons/projectiles/magic_bouncing_projectile/magic_bouncing_projectile.tscn")
		#for offset: float in [-PI/4, 0, PI/4]:
			#var dir: Vector2 = Vector2.RIGHT.rotated(rotation + offset)
			#var small_magic_bouncing_projectile: MagicBouncingProjectile = small_magic_bouncing_projectile_scene.instantiate()
			#get_parent().call_deferred("add_child", small_magic_bouncing_projectile)
			#small_magic_bouncing_projectile.call_deferred("launch", global_position, dir, speed * 1.15, true)
			#small_magic_bouncing_projectile.call_deferred("initialize_magic_bouncing_projectile", true)

	if not small:
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position - direction * 16, global_position + direction * 16, collision_mask)
		var result: Dictionary = space_state.intersect_ray(query)

		if not result.is_empty():
			var normal: Vector2 = result.normal
			var small_magic_bouncing_projectile_scene: PackedScene = load("res://Weapons/projectiles/magic_bouncing_projectile/magic_bouncing_projectile.tscn")
			for i: int in 3:
				var dir: Vector2 = normal.rotated(randf_range(-PI/2, PI/2))
				var small_magic_bouncing_projectile: MagicBouncingProjectile = small_magic_bouncing_projectile_scene.instantiate()
				get_parent().call_deferred("add_child", small_magic_bouncing_projectile)
				small_magic_bouncing_projectile.call_deferred("launch", global_position + dir * 8, dir, speed * 1.1, true)
				small_magic_bouncing_projectile.call_deferred("initialize_magic_bouncing_projectile", true)

		else: # For some reason the projectile has not found the body which it collided with. We don't count it as a bounce
			push_error("For some reason the projectile has not found the body which it collided with")
			bounces_remaining += 1

	super()
