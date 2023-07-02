extends CanvasLayer


@onready var color_rect: ColorRect = $ColorRect
@onready var pause_menu: VBoxContainer = $PauseMenu


func _ready() -> void:
	color_rect.hide()
	pause_menu.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		pause_menu.show()
		color_rect.show()
		get_tree().paused = true
