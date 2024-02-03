class_name SteamCloud extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	frame_coords.y = randi() % 4

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + Vector2(randf_range(-3, 3), randf_range(-18, -13)), animation_player.current_animation_length)
	tween.tween_property(self, "modulate:a", 0.7, animation_player.current_animation_length).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
