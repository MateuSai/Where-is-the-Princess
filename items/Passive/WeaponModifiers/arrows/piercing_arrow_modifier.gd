class_name PiercingArrowModifier extends ArrowModifier

func _init() -> void:
	type = Arrow.Type.PIERCING

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/piercing_arrow_UI_desc.png")