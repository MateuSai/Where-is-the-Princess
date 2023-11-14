extends ButtonWithSound


@onready var aim_help_container: HBoxContainer = %AimHelpHBoxContainer


func _ready() -> void:
	super()

	button_pressed = Settings.auto_aim
	aim_help_container.visible = !button_pressed
	toggled.connect(func(button_toggled: bool):
		Settings.set_auto_aim(button_toggled)
		aim_help_container.visible = !button_toggled
	)
