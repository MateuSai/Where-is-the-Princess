extends Label

func _ready() -> void:
	text = ProjectSettings.get_setting("global/version", "Error loading version")
	if OS.has_feature("demo"):
		text += "-demo"
