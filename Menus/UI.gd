extends CanvasLayer


@onready var color_rect: ColorRect = $ColorRect
@onready var pause_menu: Control = $PauseMenu
@onready var minimap: MiniMap = $MiniMap


func _ready() -> void:
	color_rect.hide()
	pause_menu.hide()
	$PauseMenu/MarginContainer/SeedLabel.text = str(Globals.run_seed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		if pause_menu.visible:
			pause_menu.hide()
			color_rect.hide()
			get_tree().paused = false
		else:
			pause_menu.show()
			color_rect.show()
			get_tree().paused = true

	if event.is_action_pressed("ui_minimap"):
		if minimap.container.visible:
			minimap.hide()
		else:
			minimap.popup_centered()
