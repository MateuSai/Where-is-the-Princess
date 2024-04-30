class_name EnhancedBoots extends PermanentPassiveItem

func _init() -> void:
	effects = [IncreasePlayerMaxSpeed.new(70)]

func get_icon() -> Texture2D:
	return load("res://Art/items/boots_icon.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/boots_UI_desc.png")
