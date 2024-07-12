class_name DemoEndScreen extends MarginContainer

func _init() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		SavedData.reset_run_stats()
		SavedData.change_biome_by_id_or_path("basecamp")
		SceneTransistor.start_transition_to("res://Game.tscn")
