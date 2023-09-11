extends MeleeWeapon

const QUAKE_PROJECTILE_SCENE: PackedScene = preload("res://Weapons/Melee/WarHammer/WarHammerQuake.tscn")

@onready var impact_point: Marker2D = $Node2D/Sprite2D/ImpactPoint


func _spawn_quake_projectiles() -> void:
	var num_projectiles: int = 10
	var rotation_separation: float = 2 * PI / num_projectiles
	var first_rotation: float = randf_range(0, rotation_separation)
	for i in num_projectiles:
		var quake_projectile: Projectile = QUAKE_PROJECTILE_SCENE.instantiate()
		get_tree().current_scene.add_child(quake_projectile)
		var dir: Vector2 = Vector2.RIGHT.rotated(first_rotation + i * rotation_separation)
		quake_projectile.launch(impact_point.global_position, dir, 120)

