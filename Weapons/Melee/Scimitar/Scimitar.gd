extends MeleeWeapon


const PROJECTILE_SCENE: PackedScene = preload("res://Weapons/Melee/Scimitar/ScimitarProjectile.tscn")


func _throw_projectile() -> void:
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
#	hitbox.exclude.push_back(projectile)
	get_tree().current_scene.add_child(projectile)
	var dir: Vector2 = Vector2.RIGHT.rotated(rotation + randf_range(-0.25, 0.25))
	projectile.launch(global_position + dir * 16, dir, 150, true)
