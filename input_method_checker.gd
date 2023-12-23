class_name InputMethodChecker extends Node
## When a [Window] is Open, the _input function of the autoloads is not called, so we have to add this node as a child of the [Window] to process the input


func _input(event: InputEvent) -> void:
	# Fix for godot 4.2
	if not get_tree().current_scene:
		return
#	print(event)
#	if event is InputEventMouseMotion:
#		print(event.as_text())
	if ((event is InputEventMouseMotion and (get_tree().current_scene.name == "Menu" or get_tree().paused)) or event is InputEventKey) and Globals.mode == Globals.Mode.CONTROLLER:
		Globals._change_to_mouse_mode()
	elif ((event is InputEventJoypadMotion and abs((event as InputEventJoypadMotion).axis_value) > 0.15) or event is InputEventJoypadButton) and Globals.mode == Globals.Mode.MOUSE:
		Globals._change_to_controller_mode(event.device)
