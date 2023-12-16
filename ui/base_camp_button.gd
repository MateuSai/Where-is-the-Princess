extends ButtonWithSound


func _ready() -> void:
	super()

	pressed.connect(func() -> void: (owner as Control).start_game())
