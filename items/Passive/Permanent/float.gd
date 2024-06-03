class_name Float extends PermanentPassiveItem

func _init() -> void:
	effects = [PlayerExtraWaterDamage.new( - 1)]

func get_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone-Complete.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone-Complete_UI_desc.png")