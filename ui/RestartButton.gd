extends Button


func _ready() -> void:
	# This only works on exported version
	pressed.connect(func():
		OS.set_restart_on_exit(true)
		get_tree().quit()
	)
