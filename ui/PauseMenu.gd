extends Control

@onready var ui: GameUI = %UI
#@onready var color_rect: ColorRect = %UIColorRect
@onready var resume_button: Button = $VBoxContainer/ResumeButton


func _ready() -> void:
	set_process_input(false)

	resume_button.pressed.connect(func() -> void:
		ui.hide_tab_container()
		#hide()
		#color_rect.hide()
		#get_tree().paused = false
	)

	draw.connect(func() -> void:
		Globals.pause_menu_opened.emit()
		set_process_input(true)
	)
	hidden.connect(func() -> void:
		Globals.pause_menu_closed.emit()
		set_process_input(false)
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		ui.hide_tab_container()
		#hide()
		#color_rect.hide()
		#get_tree().paused = false
		get_viewport().set_input_as_handled()


#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_pause"):
#		hide()
#		color_rect.hide()
#		get_tree().paused = false
