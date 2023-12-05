class_name LightningStatusComponent extends StatusComponent


const EFFECT_RANGE: int = 200


func add() -> void:
	life_component.take_damage(1, Vector2.ZERO, 0, null)

	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == character:
			continue
		var dis: float = (enemy.position - character.position).length()
		if dis <= EFFECT_RANGE:
			enemy.life_component.take_damage(1, (enemy.global_position - character.global_position).normalized(), 300, null)
			var lightning_line2d: LightningLine2D = LightningLine2D.new()
			get_tree().current_scene.add_child(lightning_line2d)
			lightning_line2d.lightning(character.global_position, enemy.global_position)

	super()

	remove()


func remove() -> void:
	super()
