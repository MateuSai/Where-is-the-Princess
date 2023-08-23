extends Control


@onready var color_rect: ColorRect = $"../ColorRect"
@onready var resume_button: Button = $VBoxContainer/ResumeButton


func _ready() -> void:
	resume_button.pressed.connect(func():
		hide()
		color_rect.hide()
		get_tree().paused = false
	)


#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_pause"):
#		hide()
#		color_rect.hide()
#		get_tree().paused = false
