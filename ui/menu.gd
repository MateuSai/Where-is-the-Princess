extends Control

func _ready() -> void:
	get_tree().current_scene.get_node("%UIColorRect").hide()

func start_game() -> void:
	SavedData._remove_and_reset_run_stats()

	var base_camp_statistics: BiomeStatistics = SavedData.statistics.get_biome_statistics("base_camp")
	if base_camp_statistics == null or base_camp_statistics.times_entered == 0:
		#SavedData.data.went_to_basecamp = true
		#SavedData.data.save()

		SceneTransistor.start_transition_to("res://ui/cinematics/intro/intro.tscn")
	else:
		SceneTransistor.start_transition_to("res://Game.tscn")
		#print_orphan_nodes()

func start_tutorial() -> void:
	#SavedData.data.played_tutorial = true
	#SavedData.data.save()

	SavedData.reset_run_stats()
	SavedData.run_stats.add_permanent_passive_item(CrystalDrop.new())
	SavedData.change_biome_by_id_or_path("tutorial_forest")
	SceneTransistor.start_transition_to("res://Game.tscn")
