extends ButtonWithSound

func _ready() -> void:
    super()

    pressed.connect(func() -> void:
        SceneTransistor.start_transition_to("res://ui/credits/credits.tscn")
    )
    