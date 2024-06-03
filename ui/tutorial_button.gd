extends ButtonWithSound

func _ready() -> void:
	super()

	pressed.connect(func() -> void:
		SavedData.reset_run_stats()
		SavedData.run_stats.add_permanent_passive_item(Float.new())
		SavedData.change_biome_by_id_or_path("tutorial_forest")
		SceneTransistor.start_transition_to("res://Game.tscn")
	, CONNECT_ONE_SHOT)
