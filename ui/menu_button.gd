extends ButtonWithSound

func _ready() -> void:
    super()

    pressed.connect(func() -> void:
        #get_tree().paused=false # This is done on ui.hide_tab_container()
        SceneTransistor.start_transition_to("res://ui/menu.tscn")
    )
