class_name Animal extends NPC

var sounds: PackedStringArray = []

var interacted_with: bool = false

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	super()

func _on_player_interacted() -> void:
	if not sounds.is_empty():
		audio_stream_player.stream = load(sounds[randi() % sounds.size()])
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
