extends CanvasLayer

# var minimap_visible: bool = false

var in_combat: bool = false

@onready var minimap: MiniMap = $MiniMap


func _ready() -> void:
	Globals.room_closed.connect(func():
		in_combat = true
		minimap.hide()
	)
	Globals.room_cleared.connect(func():
		in_combat = false
	)

	#minimap.popup_hide.connect(func(): minimap_visible = false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_minimap") and not in_combat:
		minimap.popup_centered()
		minimap.set_process(true)
