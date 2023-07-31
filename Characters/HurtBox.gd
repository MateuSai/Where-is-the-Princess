class_name HurtBox extends Area2D


var flying = true


func take_damage(dam: int, critical_dam: int, dir: Vector2, force: int, weap_id: String, damage_type: int) -> void:
	get_parent().take_damage(dam, critical_dam, dir, force, weap_id, damage_type)
