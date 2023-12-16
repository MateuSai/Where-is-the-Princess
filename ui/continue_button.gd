class_name ContinueButton extends ButtonWithSound


func _init() -> void:
	if not SavedData.are_there_run_stats():
		queue_free()


func _ready() -> void:
	super()

	pressed.connect(func() -> void:
		SceneTransistor.start_transition_to("res://Game.tscn")
	)
