extends ButtonWithSound

func _ready() -> void:
	super()

	pressed.connect(func() -> void:
		SavedData.change_biome_by_id_or_path("tutorial_forest")
		SceneTransistor.start_transition_to("res://Game.tscn")
	)
