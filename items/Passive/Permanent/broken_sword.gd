extends PermanentPassiveItem

func _init() -> void:
	effects = [IncreaseExtraDamageWhenWeaponBreaks.new(2)]

func get_icon() -> Texture2D:
	return load("res://Art/items/broken_sword_icon.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/broken_sword_UI_desc.png")
