class_name ShakeComponent extends Node

var tween: Tween


func shake(node: Node2D) -> void:
	if tween and tween.is_running():
		tween.kill()

	var initial_pos: Vector2 = node.position
	var dir: Vector2 = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
	tween = create_tween()
	for i: int in 3:
		tween.tween_property(node, "position", initial_pos + dir * randf_range(0.8, 1.3), 0.1)
		dir = dir.rotated(PI + randf_range(-0.5, 0.5))

	tween.tween_property(node, "position", initial_pos, 0.1)
