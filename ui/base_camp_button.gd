extends ButtonWithSound

func _ready() -> void:
	super()

	pressed.connect(func() -> void:
		if SavedData.are_there_run_stats():
			_confirm_overwrite_save()
		else:
			if not SavedData.data.went_to_basecamp:
				if not SavedData.data.played_tutorial:
					_confirm_go_to_basecamp_without_doing_tutorial()
					return

			(owner as Control).start_game()
	)

func _confirm_overwrite_save() -> void:
	var base_camp_popup_confirmation: PopupConfirmation = load("res://ui/base_camp_popup_confirmation/base_camp_popup_confirmation.tscn").instantiate()
	owner.add_child(base_camp_popup_confirmation)

	base_camp_popup_confirmation.confirmed.connect(func() -> void:
		SavedData._remove_and_reset_run_stats()

		(owner as Control).start_game()
	, CONNECT_ONE_SHOT)

func _confirm_go_to_basecamp_without_doing_tutorial() -> void:
	var base_camp_tutorial_popup_confirmation: PopupConfirmation = load("res://ui/base_camp_tutorial_popup_confirmation/base_camp_tutorial_popup_confirmation.tscn").instantiate()
	owner.add_child(base_camp_tutorial_popup_confirmation)

	base_camp_tutorial_popup_confirmation.confirmed.connect(owner.start_tutorial, CONNECT_ONE_SHOT)
	base_camp_tutorial_popup_confirmation.popup_hide.connect(owner.start_game, CONNECT_ONE_SHOT)