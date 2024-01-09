class_name ShadowSprite extends Sprite2D


@warning_ignore("shadowed_variable_base_class")
func start(texture: Texture, time: float = 0.25) -> void:
	self.texture = texture

	var tween: Tween = create_tween()
	tween.finished.connect(queue_free)
	tween.tween_property(self, "modulate:a", 0.0, time)
