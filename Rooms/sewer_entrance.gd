class_name SewerEntrance extends StaticBody2D


func _ready() -> void:
	($InteractArea as InteractArea).player_interacted.connect(func() -> void:
		if OS.has_feature("demo"):
			SceneTransistor.start_transition_to("res://ui/demo_end_screen/demo_end_screen.tscn")
		else:
			Globals.exit_level("sewer")
	)
