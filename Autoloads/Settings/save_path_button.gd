class_name SavePathButton extends ButtonWithSound


@onready var file_dialog: FileDialog = %FileDialog


func _ready() -> void:
	super()

	pressed.connect(func() -> void:
		file_dialog.popup_centered()
	)
