class_name AdditionalStartCoins extends PlayerUpgrade

func _init() -> void:
	effects = [ExtraInitialCoins.new(10)]

func get_icon() -> Texture2D:
	return load("res://Art/items/piggy_icon.png")


func get_dark_soul_cost() -> int:
	return 3


func get_max_amount() -> int:
	return 4
