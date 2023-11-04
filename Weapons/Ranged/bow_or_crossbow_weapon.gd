class_name BowOrCrossbowWeapon extends RangedWeapon


signal arrow_type_changed(new_type: Arrow.Type)
var arrow_type: Arrow.Type = Arrow.Type.NORMAL:
	set(new_type):
#		print("New arrow type is: " + Arrow.Type.keys()[new_type])
		arrow_type = new_type
		arrow_type_changed.emit(arrow_type)


func _spawn_projectile(angle: float = 0.0, amount: int = 1) -> Array[Projectile]:
	var spawned_projectiles: Array[Projectile] = super(angle, amount)

	for projectile in spawned_projectiles:
		assert(projectile is Arrow)
		projectile.type = arrow_type

	return spawned_projectiles
