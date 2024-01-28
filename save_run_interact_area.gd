class_name SaveRunInteractArea extends InteractArea


func _ready() -> void:
	super()

	player_interacted.connect(func() -> void:
		SavedData.save_run_stats()
		SceneTransistor.start_transition_to("res://ui/menu.tscn")
	)
