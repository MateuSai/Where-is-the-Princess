class_name SplashScreen extends Control


@export var _time: float = 3
@export var _fade_time: float = 1

signal finished()


func start() -> void:
	modulate.a = 0
	show()
	var tween: Tween = create_tween()
	tween.finished.connect(_finish)
	tween.tween_property(self, "modulate:a", 1, _fade_time)
	tween.tween_interval(_time)
	tween.tween_property(self, "modulate:a", 0, _fade_time)


func _finish() -> void:
	finished.emit()
	queue_free()
