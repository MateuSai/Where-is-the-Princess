class_name WeaponFragment extends Node2D

@onready var polygon: Polygon2D = $Polygon2D
@onready var area: Area2D = $Area2D

func throw(thrower_body: Node, dir: Vector2, weapon_texture: Texture2D, fragment_points: PackedVector2Array) -> void:
	assert(fragment_points.size() == 3)

	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

	polygon.texture = weapon_texture
	polygon.polygon = fragment_points
	polygon.uv = fragment_points

	var center: Vector2 = Vector2((fragment_points[0].x + fragment_points[1].x + fragment_points[2].x) / 3.0, (fragment_points[0].y + fragment_points[1].y + fragment_points[2].y) / 3.0)
	polygon.position = -center

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	var time: float = 0.5
	tween.tween_property(self, "position", position + dir * randf_range(18, 36), time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", [1, -1][randi() % 2] * randf_range(0.8, 5), time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	area.body_entered.connect(func(body: Node) -> void:
		if body == thrower_body:
			return

		if tween.is_valid():
			tween.kill()
	)
