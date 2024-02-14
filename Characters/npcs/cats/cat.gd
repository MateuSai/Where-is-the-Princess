@icon("res://Art/cat_black_0.png")
class_name Cat extends NPC

var interacted_with: bool = false


func _on_player_interacted() -> void:
	if not interacted_with:
		interacted_with = true
		SavedData.run_stats.luck += 1
		_spawn_heart()


func _spawn_heart() -> void:
	var heart: Sprite2D = Sprite2D.new()
	heart.texture = load("res://Art/cat_interaction_UI.png")
	heart.position = Vector2(-8, -12)
	add_child(heart)

	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_property(heart, "position:y", heart.position.y - 8, 0.7).set_delay(1.0)
	t.tween_property(heart, "modulate:a", 0.0, 0.7).set_delay(1.0)
	await t.finished
	t.tween_callback(heart.queue_free)
