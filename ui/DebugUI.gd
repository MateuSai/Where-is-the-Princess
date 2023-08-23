extends Control

@onready var debug_info: VBoxContainer = $DebugInfo
@onready var terminal: LineEdit = $Terminal


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_open_terminal") and debug_info.visible:
		terminal.show()
	elif event.is_action_pressed("ui_cancel") and terminal.visible:
		terminal.hide()
