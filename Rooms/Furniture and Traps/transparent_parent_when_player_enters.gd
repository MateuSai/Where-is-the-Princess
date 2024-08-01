class_name TransparentParentWhenPlayerEnters extends Area2D

var tween: Tween

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player

	body_entered.connect(func(body: Node) -> void:
		if not body is Player:
			return

		if tween:
			tween.kill()

		tween = create_tween()
		tween.tween_property(get_parent(), "modulate:a", 0.0, 0.3)
	)

	body_exited.connect(func(body: Node) -> void:
		if not body is Player:
			return

		if tween:
			tween.kill()

		tween = create_tween()
		tween.tween_property(get_parent(), "modulate:a", 1.0, 0.3)
	)
