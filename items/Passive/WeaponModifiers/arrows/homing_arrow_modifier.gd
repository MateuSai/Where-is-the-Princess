class_name HomingArrowModifier extends ArrowModifier

func _init() -> void:
	type = Arrow.Type.HOMING

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/homing_arrow_UI_desc.png")