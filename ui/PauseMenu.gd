extends Control

@onready var ui: GameUI = %UI
#@onready var color_rect: ColorRect = %UIColorRect
@onready var resume_button: Button = $VBoxContainer/ResumeButton


func _ready() -> void:
	resume_button.pressed.connect(func() -> void:
		ui.hide_tab_container()
		#hide()
		#color_rect.hide()
		#get_tree().paused = false
	)

	visibility_changed.connect(func() -> void:
		if visible:
			Globals.pause_menu_opened.emit()
		else:
			Globals.pause_menu_closed.emit()
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
