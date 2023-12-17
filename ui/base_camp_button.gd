extends ButtonWithSound


@onready var base_camp_confirmation_dialog: ConfirmationDialog = $"../../BaseCampConfirmationDialog"

func _ready() -> void:
	super()

	base_camp_confirmation_dialog.confirmed.connect(func() -> void:
		SavedData._remove_and_reset_run_stats()

		(owner as Control).start_game()
	)

	pressed.connect(func() -> void:
		if SavedData.are_there_run_stats():
			base_camp_confirmation_dialog.popup_centered()
		else:
			(owner as Control).start_game()
	)
