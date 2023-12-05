class_name WoodFragment extends Sprite2D


func throw(dir: Vector2) -> void:
	texture = load("res://Art/crate/wood-particle_0" + str((randi() % 6) + 1) + ".png")
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	var time: float = 0.5
	tween.tween_property(self, "position", position + dir * randf_range(18, 36), time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", [1, -1][randi() % 2] * randf_range(0.8, 5), time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
