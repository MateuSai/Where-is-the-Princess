class_name PopupConfirmation extends PopupPanel

signal confirmed()


func _ready() -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 32)

	var confirm_button: TextureButton = TextureButton.new()
	confirm_button.texture_normal = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/ok_button_normal.png")
	confirm_button.texture_hover = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/ok_button_hover.png")
	confirm_button.texture_pressed = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/ok_button_pressed.png")
	confirm_button.pressed.connect(func() -> void:
		confirmed.emit()
		hide()
	)
	hbox.add_child(confirm_button)

	var cancel_button: TextureButton = TextureButton.new()
	cancel_button.texture_normal = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/cancel_button_normal.png")
	cancel_button.texture_hover = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/cancel_button_hover.png")
	cancel_button.texture_pressed = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/cancel_button_pressed.png")
	cancel_button.pressed.connect(func() -> void:
		hide()
	)
	hbox.add_child(cancel_button)

	get_child(0).add_child(hbox)
