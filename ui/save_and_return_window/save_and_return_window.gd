class_name SaveAndReturnWindow extends ConfirmationDialog

@onready var dont_ask_again_check_box: CheckBox = %DontAskAgainCheckBox


func _ready() -> void:
	get_tree().paused = true
	get_tree().current_scene.get_node("%UIColorRect").show()

	confirmed.connect(func() -> void:
		if dont_ask_again_check_box.button_pressed:
			SavedData.data.set_show_save_and_return_window(false)
	)

	visibility_changed.connect(func() -> void:
		get_tree().paused = false
		get_tree().current_scene.get_node("%UIColorRect").hide()
	)
