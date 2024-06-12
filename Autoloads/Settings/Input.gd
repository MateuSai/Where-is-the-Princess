extends ScrollContainer

const PRESS_ANY_KEY_SCREEN_SCENE: PackedScene = preload ("res://ui/press_any_key_screen.tscn")

@onready var press_any_key_screen: CanvasLayer = owner.get_node("PressAnyKeyScreen")

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
	press_any_key_screen.show()
	#press_any_key_screen = PRESS_ANY_KEY_SCREEN_SCENE.instantiate()
	#get_tree().root.add_child(press_any_key_screen)
#
#
func _hide_press_any_key_screen() -> void:
	press_any_key_screen.hide()
	#if is_instance_valid(press_any_key_screen):
	#	press_any_key_screen.free()
	#	press_any_key_screen = null
