extends Control

@onready var pause_menu: Control = get_node("../PauseMenu")

@onready var debug_info: VBoxContainer = $DebugInfo
@onready var terminal: LineEdit = $Terminal


func _ready() -> void:
	if not Globals.debug:
		queue_free()

	terminal.hidden.connect(func() -> void:
		pause_menu.set_process_input(true)
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_terminal") and debug_info.visible:
		terminal.show()
		pause_menu.set_process_input(false)
	elif (event.is_action_pressed("ui_toggle_terminal") or event.is_action_pressed("ui_cancel")) and terminal.visible:
		terminal.hide()
		pause_menu.set_process_input(true)
		get_viewport().set_input_as_handled()
