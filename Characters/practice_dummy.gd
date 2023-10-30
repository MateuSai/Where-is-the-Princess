class_name PracticeDummy extends Character


func _on_damage_taken(dam: int, dir: Vector2, force: int) -> void:
	super(dam, dir, force)

	life_component.hp += dam # So the dummy never dies
