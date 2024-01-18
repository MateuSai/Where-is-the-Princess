extends Control


func start_game() -> void:
	# SavedData.load_mods()
	SceneTransistor.start_transition_to("res://Game.tscn")
	#print_orphan_nodes()
