extends MeleeWeapon

const QUAKE_PROJECTILE_SCENE: PackedScene = preload("res://Weapons/Melee/KombatHammer/KombatHammerQuake.tscn")

const SPREAD: float = 0.4
const TOTAL_ROTATION: float = SPREAD * 2


func _spawn_quake_projectiles() -> void:
	var num_projectiles: int = 6
	var first_rotation: float = rotation - SPREAD
	var rotation_per_projectile: float = TOTAL_ROTATION / (num_projectiles-1)
	for i: int in num_projectiles:
		var quake_projectile: Projectile = QUAKE_PROJECTILE_SCENE.instantiate()
		get_tree().current_scene.add_child(quake_projectile)
		var dir: Vector2 = Vector2.RIGHT.rotated(first_rotation + i * rotation_per_projectile)
		quake_projectile.launch(global_position + dir * 16, dir, 150)
