class_name Credits extends ScrollContainer

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.keycode in [KEY_ESCAPE]:
            SceneTransistor.start_transition_to("res://ui/menu.tscn")