extends Control


func start_game() -> void:
	# SavedData.load_mods()
	SceneTransistor.start_transition_to("res://BaseCamp.tscn")
	#print_orphan_nodes()
