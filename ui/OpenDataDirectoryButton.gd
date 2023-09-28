extends ButtonWithSound


func _ready() -> void:
	super()

	pressed.connect(func():
		OS.shell_open(ProjectSettings.globalize_path("user://"))
	)
