class_name Target extends PermanentArtifact

func _init() -> void:
	effects = [IncreaseThrowPiercing.new(1)]

func get_icon() -> Texture2D:
	return load("res://Art/items/Bolt_icon.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Bolt_UI_desc.png")
