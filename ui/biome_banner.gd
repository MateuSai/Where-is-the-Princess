class_name BiomeBanner extends PanelContainer

@onready var label: Label = $MarginContainer/Label
@onready var initial_delay_timer: Timer = $InitialDelayTimer

func _ready() -> void:
    hide()

    initial_delay_timer.timeout.connect(start)
    initial_delay_timer.start()

func start() -> void:
    label.text = SavedData.get_biome_conf().name
    
    modulate.a = 0.0
    show()

    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate:a", 1.0, 0.4)
    tween.tween_interval(3.5)
    tween.tween_property(self, "modulate:a", 0.0, 0.4)
    tween.tween_callback(queue_free) # Anyway we don't need the banner anymore