extends ButtonWithSound


func _ready() -> void:
	super()

	pressed.connect(get_tree().quit)
