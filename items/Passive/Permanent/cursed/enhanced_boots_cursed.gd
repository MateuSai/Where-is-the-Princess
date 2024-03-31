class_name EnhancedBootsCursed extends CursedPermanentPassiveItem


func _init() -> void:
	effects = [PlayerMaxSpeed.new(110), PlayerExtraDamageTaken.new(1)]


func get_icon() -> Texture2D:
	return load("res://Art/items/boots_icon.png")


func get_big_icon() -> Texture2D:
	return load("res://Art/items/boots_UI_desc.png")
