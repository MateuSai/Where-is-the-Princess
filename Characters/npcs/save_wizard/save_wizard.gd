class_name SaveWizard extends NPC


func _ready() -> void:
	super()

	interact_area.player_interacted.connect(func() -> void:
		SavedData.save_run_stats()
		SceneTransistor.start_transition_to("res://ui/menu.tscn")
	)
