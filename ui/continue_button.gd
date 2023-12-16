class_name ContinueButton extends ButtonWithSound


func _ready() -> void:
	super()

	if not SavedData.are_there_run_stats():
		queue_free()

	pressed.connect(func() -> void:
		SceneTransistor.start_transition_to("res://Game.tscn")
	)
