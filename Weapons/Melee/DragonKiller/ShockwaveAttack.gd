extends Hitbox

const SHOCKWAVE_PROJECTILE: PackedScene = preload("res://Weapons/Melee/DragonKiller/ShockwaveProjectile.tscn")


func _ready() -> void:
	super()

	_spawn_shockwave_projectiles()


func _spawn_shockwave_projectiles() -> void:
	var num_projectiles: int = randi_range(8, 16)
	var initial_angle: float = randf_range(0, 2*PI/num_projectiles)
	for i in num_projectiles:
		var projectile: Sprite2D = SHOCKWAVE_PROJECTILE.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.launch(position, Vector2.RIGHT.rotated(initial_angle + i * 2*PI/num_projectiles) , 150)


func _collide(node: Node2D, dam: int = damage) -> void:
	knockback_direction = (node.global_position - global_position).normalized()

	super(node, dam)
