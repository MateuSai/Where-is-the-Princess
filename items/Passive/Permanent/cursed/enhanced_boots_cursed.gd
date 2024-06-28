class_name EnhancedBootsCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [
		IncreasePlayerMaxSpeed.new(110),
		IncreaseDashStaminaCost.new( - 12),
		PlayerExtraDamageTaken.new(1)
	]

func get_icon() -> Texture2D:
	return load("res://Art/items/boots_icon_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/boots_UI_cursed_desc.png")
