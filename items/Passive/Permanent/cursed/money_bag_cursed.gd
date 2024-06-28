class_name MoneyBagCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [
		IncreaseCoinMultiplier.new(2.0),
		OnPlayerDamaged.new([RemoveCoins.new(1)])
	]

func get_icon() -> Texture2D:
	return load("res://Art/items/money_bag_icon_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/money_bag_cursed_UI_desc.png")
