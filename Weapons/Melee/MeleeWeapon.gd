class_name MeleeWeapon extends Weapon


func _ready() -> void:
	super()
	hitbox.collided_with_something.connect(_on_collided_with_something)


func _on_collided_with_something() -> void:
	stats.set_condition(stats.condition - condition_degrade_by_attack)
