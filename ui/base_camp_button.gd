extends ButtonWithSound

func _ready() -> void:
	super()

	pressed.connect(func() -> void:
		if SavedData.are_there_run_stats():
			_confirm_overwrite_save()
		else:
			var base_camp_statistics: BiomeStatistics=SavedData.statistics.get_biome_statistics("base_camp")
			if base_camp_statistics == null or base_camp_statistics.times_entered == 0:
				var tutorial_forest_statistics: BiomeStatistics=SavedData.statistics.get_biome_statistics("tutorial_forest")
				if tutorial_forest_statistics == null or tutorial_forest_statistics.times_entered == 0:
					_confirm_go_to_basecamp_without_doing_tutorial()
					return

			(owner as Control).start_game()
	)

func _confirm_overwrite_save() -> void:
	var base_camp_popup_confirmation: PopupConfirmation = load("res://ui/base_camp_popup_confirmation/base_camp_popup_confirmation.tscn").instantiate()
	owner.add_child(base_camp_popup_confirmation)

	base_camp_popup_confirmation.confirmed.connect(func() -> void:
		(owner as Control).start_game()
	, CONNECT_ONE_SHOT)

func _confirm_go_to_basecamp_without_doing_tutorial() -> void:
	var base_camp_tutorial_popup_confirmation: PopupConfirmation = load("res://ui/base_camp_tutorial_popup_confirmation/base_camp_tutorial_popup_confirmation.tscn").instantiate()
	owner.add_child(base_camp_tutorial_popup_confirmation)

	base_camp_tutorial_popup_confirmation.confirmed.connect(owner.start_tutorial, CONNECT_ONE_SHOT)
	base_camp_tutorial_popup_confirmation.popup_hide.connect(owner.start_game, CONNECT_ONE_SHOT)