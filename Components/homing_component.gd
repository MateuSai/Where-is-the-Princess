class_name HomingComponent extends EnemyDetector

var homing_degree: float

@onready var projectile: Projectile = get_parent()


func _ready() -> void:
#	set_collision_layer_value(1, false)
#	set_collision_mask_value(1, false)
#	set_collision__value(3, true) # enemies
	super()

	_enable()


func _physics_process(_delta: float) -> void:
	var dir: Vector2 = get_direction()
	if dir != Vector2.ZERO:
		#print((1.1 - abs(projectile.direction.angle_to(dir)) / PI))
		projectile.direction = Vector2.RIGHT.rotated(lerp_angle(projectile.direction.angle(), dir.angle(), homing_degree * (1.1 - abs(projectile.direction.angle_to(dir)) / PI)))


func get_direction() -> Vector2:
	return (closer_enemy.global_position - projectile.position).normalized() if is_instance_valid(closer_enemy) else Vector2.ZERO


func _update_closer_enemy() -> void:
	var distance_to_closer_enemy: float = (closer_enemy.global_position - projectile.position).length() if is_instance_valid(closer_enemy) else INF
	for enemy: Character in enemies_inside:
		if enemy == closer_enemy:
			continue
		var distance_to_other_enemy: float = (enemy.global_position - projectile.position).length()
		if distance_to_other_enemy < distance_to_closer_enemy:
			distance_to_closer_enemy = distance_to_other_enemy
			closer_enemy = enemy
