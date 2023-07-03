extends Button


func _ready() -> void:
	pressed.connect(Settings.popup_centered)
