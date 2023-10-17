class_name Arrow extends Projectile


func _collide(body: Node2D, _dam: int = damage) -> void:
	if body.get("life_component") != null:
		body.life_component.take_damage(damage, knockback_direction, knockback_force)
	_attach_projectile(body)


func _attach_projectile(body: Node2D) -> void:
	var sprite_clone: Sprite2D = $Sprite2D.duplicate()

	if body is CharacterBody2D:
		body.add_child(sprite_clone)
	else:
		get_tree().current_scene.add_child(sprite_clone)

	sprite_clone.rotation += rotation
	sprite_clone.global_position = position

	destroy()
