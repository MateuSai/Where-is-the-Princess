extends ButtonWithSound

func _ready() -> void:
	if OS.has_feature("demo"):
		queue_free()
		return

	super()

	#pressed.connect(func(): owner.add_child(ModMenu.new()))
	pressed.connect(func() -> void: (get_tree().root.get_node("UserProfiles") as UserProfilesPopup).popup_centered())
