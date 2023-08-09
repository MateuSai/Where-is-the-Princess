class_name LightningStatusComponent extends StatusComponent


const EFFECT_RANGE: int = 200


func add() -> void:
	life_component.take_damage(1, Vector2.ZERO, 0)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == get_parent():
			continue
		var dis: float = (enemy.position - get_parent().position).length()
		if dis <= EFFECT_RANGE:
			enemy.life_component.take_damage(1, (enemy.position - get_parent().position).normalized(), 300)
			var lightning_line2d: Line2D = LightningLine2D.new()
			get_tree().current_scene.add_child(lightning_line2d)
			lightning_line2d.lightning(get_parent().global_position, enemy.global_position)

	super()

	remove()


func remove() -> void:
	super()
