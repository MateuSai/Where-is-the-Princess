@icon("res://Art/cat_black_0.png")
class_name Cat extends NPC

const CAT_SOUNDS: PackedStringArray = ["res://Audio/Sounds/cat/小次郎/1.wav", "res://Audio/Sounds/cat/小次郎/2.wav", "res://Audio/Sounds/cat/小次郎/3_amplified.wav", "res://Audio/Sounds/cat/小次郎/5_amplified.wav", "res://Audio/Sounds/cat/小次郎/6_amplified.wav"]

var interacted_with: bool = false

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_player_interacted() -> void:
	audio_stream_player.stream = load(CAT_SOUNDS[randi() % CAT_SOUNDS.size()])
	audio_stream_player.play()

	if not interacted_with:
		interacted_with = true
		SavedData.run_stats.luck += 1
		_spawn_heart()

func _spawn_heart() -> void:
	var heart: Sprite2D = Sprite2D.new()
	heart.texture = load("res://Art/cat_interaction_UI.png")
	heart.position = Vector2( - 8, -12)
	add_child(heart)

	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_property(heart, "position:y", heart.position.y - 8, 0.7).set_delay(0.4)
	t.tween_property(heart, "modulate:a", 0.0, 0.7).set_delay(0.4)
	t.chain()
	t.tween_callback(heart.queue_free)
