extends ButtonWithSound


func _ready() -> void:
	super()

	# This only works on exported versionr
	pressed.connect(func() -> void:
		OS.set_restart_on_exit(true)
		get_tree().quit()
	)
