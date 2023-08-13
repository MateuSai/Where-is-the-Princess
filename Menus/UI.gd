extends CanvasLayer

# var minimap_visible: bool = false

var in_combat: bool = false

@onready var color_rect: ColorRect = $ColorRect
@onready var pause_menu: Control = $PauseMenu
@onready var minimap: MiniMap = $MiniMap


func _ready() -> void:
	color_rect.hide()
	pause_menu.hide()
	$PauseMenu/MarginContainer/SeedLabel.text = str(Globals.run_seed)

	Globals.room_closed.connect(func():
		in_combat = true
		minimap.hide()
	)
	Globals.room_cleared.connect(func():
		in_combat = false
	)

	#minimap.popup_hide.connect(func(): minimap_visible = false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		if pause_menu.visible:
			pause_menu.hide()
			color_rect.hide()
			get_tree().paused = false
		else:
			pause_menu.show()
			color_rect.show()
			get_tree().paused = true

	if event.is_action_pressed("ui_minimap") and not in_combat:
		minimap.popup_centered()
		minimap.set_process(true)
