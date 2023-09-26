extends ButtonWithSound


func _ready() -> void:
	super()

	pressed.connect(Settings.popup_centered)
