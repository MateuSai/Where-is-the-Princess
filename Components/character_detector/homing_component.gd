class_name HomingComponent extends CharacterDetector

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
		var weight: float = homing_degree * (1.1 - abs(projectile.direction.angle_to(dir)) / PI)
		projectile.direction = Vector2.RIGHT.rotated(lerp_angle(projectile.direction.angle(), dir.angle(), weight))


func get_direction() -> Vector2:
	return projectile.get_direction_to(closer_enemy) if is_instance_valid(closer_enemy) else Vector2.ZERO
