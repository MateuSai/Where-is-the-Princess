class_name ExplosiveArrowModifier extends ArrowModifier

func _init() -> void:
	type = Arrow.Type.EXPLOSIVE

func get_quality() -> Quality:
	return Quality.COMMON

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/explosive_arrow_UI_desc.png")