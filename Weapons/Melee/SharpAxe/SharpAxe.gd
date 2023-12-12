extends MeleeWeapon

const PROJECTILE_SCENE: PackedScene = preload("res://Weapons/Melee/SharpAxe/SharpAxeProjectile.tscn")


func _throw_projectile() -> void:
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	get_tree().current_scene.add_child(projectile)
	var dir: Vector2 = Vector2.RIGHT.rotated(rotation + deg_to_rad(90) + ($Node2D as Node2D).rotation)
	projectile.launch(global_position + dir * 16, dir, 150, true)
