extends ButtonWithSound


func _ready() -> void:
	super()

	pressed.connect(func(): owner.start_game())
