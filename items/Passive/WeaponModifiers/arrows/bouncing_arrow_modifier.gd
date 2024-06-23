class_name BouncingArrowModifier extends ArrowModifier

func _init() -> void:
	type = Arrow.Type.BOUNCING

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/bouncing_arrow_UI_desc.png")