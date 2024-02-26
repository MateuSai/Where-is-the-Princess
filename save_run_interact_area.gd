class_name SaveRunInteractArea extends InteractArea

const SAVE_AND_RETURN_WINDOW_SCENE: PackedScene = preload("res://ui/save_and_return_window/save_and_return_window.tscn")


func _ready() -> void:
	super()

	player_interacted.connect(func() -> void:
		if SavedData.data.show_save_and_return_window:
			var window: SaveAndReturnWindow = SAVE_AND_RETURN_WINDOW_SCENE.instantiate()
			window.confirmed.connect(_save_and_return_to_menu)
			get_tree().current_scene.add_child(window)
			window.popup_centered()
		else:
			_save_and_return_to_menu()
	)


func _save_and_return_to_menu() -> void:
	if SavedData.get_biome_conf().name != "BASE_CAMP":
		SavedData.save_run_stats()
	else:
		SavedData.run_stats = RunStats.new()
	SceneTransistor.start_transition_to("res://ui/menu.tscn")
