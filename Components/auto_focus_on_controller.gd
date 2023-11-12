class_name AutoFocusOnController extends Node

var control_with_focus: Control = null

@onready var owner_control: Control = owner


func _ready() -> void:
	get_viewport().gui_focus_changed.connect(func(new_control_with_focus: Control):
		if new_control_with_focus:
			control_with_focus = new_control_with_focus
	)

	if Globals.mode == Globals.Mode.CONTROLLER:
		_focus_first_control()

	Globals.mode_changed.connect(func(new_mode: Globals.Mode):
		if new_mode == Globals.Mode.CONTROLLER:
			_focus_first_control()
		else:
			if control_with_focus:
				control_with_focus.release_focus()
				control_with_focus = null
	)


func _focus_first_control() -> void:
	var control_to_focus: Control = _check_children(owner_control)
	if control_to_focus:
		control_to_focus.grab_focus()
	else:
		push_error("There is no control that can grab push")

func _check_children(control: Control) -> Control:
	for child_control in control.get_children():
		if child_control is Control and child_control.focus_mode == Control.FOCUS_ALL:
			return child_control
		else:
			var focusable_child_of_child: Control = _check_children(child_control)
			if focusable_child_of_child:
				return focusable_child_of_child

	return null
