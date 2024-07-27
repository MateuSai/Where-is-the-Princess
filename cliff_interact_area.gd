class_name CliffInteractArea extends InteractArea

func _ready() -> void:
	super()

	player_interacted.connect(func() -> void:
		SceneTransistor.start_transition_to("res://ui/cinematics/cliff_jump/cliff_jump.tscn")
	, CONNECT_ONE_SHOT)
