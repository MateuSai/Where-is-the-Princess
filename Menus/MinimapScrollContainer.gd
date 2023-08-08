class_name MinimapScrollContainer extends ScrollContainer

var drag_enabled: bool = false
var mouse_pos_at_start_of_drag: Vector2
var scroll_horizontal_at_start_of_drag: int = 0
var scroll_vertical_at_start_of_drag: int = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_drag_minimap"):
		mouse_pos_at_start_of_drag = get_local_mouse_position()
		scroll_horizontal_at_start_of_drag = scroll_horizontal
		scroll_vertical_at_start_of_drag = scroll_vertical
		drag_enabled = true
		set_process(true)
	if event.is_action_released("ui_drag_minimap"):
		drag_enabled = false
		set_process(false)


func _process(_delta: float) -> void:
	if drag_enabled:
		@warning_ignore("narrowing_conversion")
		scroll_horizontal = scroll_horizontal_at_start_of_drag - get_local_mouse_position().x + mouse_pos_at_start_of_drag.x
		@warning_ignore("narrowing_conversion")
		scroll_vertical = scroll_vertical_at_start_of_drag - get_local_mouse_position().y + mouse_pos_at_start_of_drag.y
