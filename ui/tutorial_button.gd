class_name TutorialButton extends ButtonWithSound

func _ready() -> void:
	super()

	pressed.connect(owner.start_tutorial, CONNECT_ONE_SHOT)