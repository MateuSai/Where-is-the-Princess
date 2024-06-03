class_name HurtBox extends Area2D

#var flying: bool = true

#func take_damage(dam: int, critical_dam: int, dir: Vector2, force: int, weap_id: String, damage_type: int) -> void:
#	var parent: Node2D = get_parent()
#	assert(parent.has_method("take_damage"))
#	@warning_ignore("unsafe_method_access")
#	parent.take_damage(dam, critical_dam, dir, force, weap_id, damage_type)
