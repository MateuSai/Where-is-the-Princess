class_name WeaponFragment extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var col: CollisionShape2D = $Area2D/CollisionShape2D

func throw(thrower_body: Node, dir: Vector2, weapon_texture: Texture2D) -> void:
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

	sprite.texture = weapon_texture
	var rectangle_shape: RectangleShape2D = RectangleShape2D.new()
	rectangle_shape.size = sprite.texture.get_size()
	col.shape = rectangle_shape

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
