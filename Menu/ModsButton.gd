extends Button


func _ready() -> void:
	pressed.connect($"../../PopupPanel".popup_centered)
