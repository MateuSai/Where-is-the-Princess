class_name BiomeBanner extends Control

@onready var game: Game = owner

@onready var label: Label = $Panel/MarginContainer/Label
@onready var initial_delay_timer: Timer = $Panel/InitialDelayTimer

func _ready() -> void:
	hide()

	initial_delay_timer.timeout.connect(start)

	game.generation_reloaded.connect(_on_generation_reloaded)
	_on_generation_reloaded()

func _on_generation_reloaded() -> void:
	game.player_added.connect(initial_delay_timer.start)

func start() -> void:
	label.text = SavedData.get_biome_conf().name

	modulate.a = 0.0
	show()

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.tween_interval(3.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free) # Anyway we don't need the banner anymore
