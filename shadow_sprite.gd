class_name ShadowSprite extends Sprite2D


func start(texture: Texture, time: float = 0.3) -> void:
	self.texture = texture

	var tween: Tween = create_tween()
	tween.finished.connect(queue_free)
	tween.tween_property(self, "modulate:a", 0.0, time)
