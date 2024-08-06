extends ScrollContainer

const PRESS_ANY_KEY_SCREEN_SCENE: PackedScene = preload ("res://ui/press_any_key_screen.tscn")

@onready var press_any_key_screen: Popup = owner.get_node("PressAnyKeyScreenPopup")

@onready var vbox: VBoxContainer = $MarginContainer/VBoxContainer

func _ready() -> void:
	press_any_key_screen.hide()


	for action_name: String in Settings.MAPPEABLE_ACTIONS:
		var row: KeybindingRow = KeybindingRow.new(action_name)
		vbox.add_child(row)
		#move_child(row, get_child_count() - 2)
		row.pressed.connect(func() -> void:
			_show_press_any_key_screen(row)
		)
		row.key_selected.connect(func() -> void:
			_hide_press_any_key_screen(row)
		)

func _show_press_any_key_screen(row: KeybindingRow) -> void:
	#press_any_key_screen.position = press_any_key_screen.size/2 - Vector2()
	press_any_key_screen.show()
	press_any_key_screen.input_received.connect(row._input)
	#press_any_key_screen = PRESS_ANY_KEY_SCREEN_SCENE.instantiate()
	#get_tree().root.add_child(press_any_key_screen)
#
#
func _hide_press_any_key_screen(row: KeybindingRow) -> void:
	press_any_key_screen.hide()
	press_any_key_screen.input_received.disconnect(row._input)
	#if is_instance_valid(press_any_key_screen):
	#	press_any_key_screen.free()
	#	press_any_key_screen = null
