extends ScrollContainer

@onready var press_any_key_screen: CanvasLayer = get_node("PressAnyKeyScreen")

@onready var vbox: VBoxContainer = $MarginContainer/VBoxContainer


func _ready() -> void:
	_hide_press_any_key_screen()

	for action_name: String in Settings.MAPPEABLE_ACTIONS:
		var row: KeybindingRow = KeybindingRow.new(action_name)
		vbox.add_child(row)
		#move_child(row, get_child_count() - 2)
		row.pressed.connect(_show_press_any_key_screen)
		row.key_selected.connect(_hide_press_any_key_screen)


func _show_press_any_key_screen() -> void:
	press_any_key_screen.visible = true
#
#
func _hide_press_any_key_screen() -> void:
	press_any_key_screen.visible = false
