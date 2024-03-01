class_name Fragment extends Sprite2D

@export var textures: Array[Texture2D] = []

@onready var area: Area2D = $Area2D


func _ready() -> void:
	assert(not textures.is_empty())


func throw(thrower_body: Node, dir: Vector2) -> void:
	texture = textures[randi() % textures.size()]
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
