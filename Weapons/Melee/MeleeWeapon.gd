class_name MeleeWeapon extends Weapon


func _ready() -> void:
	super()
	hitbox.collided_with_something.connect(_on_collided_with_something)


func _on_collided_with_something(col_mat: Hitbox.CollisionMaterial) -> void:
	# Double degrade amount if we collide with stone
	stats.set_condition(stats.condition - round(condition_degrade_by_attack * (col_mat+1)))
