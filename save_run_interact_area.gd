class_name SaveRunInteractArea extends InteractArea


func _ready() -> void:
	super()

	player_interacted.connect(func() -> void:
		if SavedData.get_biome_conf().name != "BASE_CAMP":
			SavedData.save_run_stats()
		else:
			SavedData.run_stats = RunStats.new()
		SceneTransistor.start_transition_to("res://ui/menu.tscn")
	)
