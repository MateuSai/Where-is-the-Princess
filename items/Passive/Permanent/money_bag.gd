extends PermanentPassiveItem

func _init() -> void:
	effects = [IncreaseCoinMultiplier.new(1.3)]

func get_icon() -> Texture2D:
	return load("res://Art/items/money_bag_icon.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/money_bag_UI_desc.png")
