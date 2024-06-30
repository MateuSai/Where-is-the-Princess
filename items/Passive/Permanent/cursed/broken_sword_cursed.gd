class_name BrokenSwordCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [
		IncreaseExtraDamageWhenWeaponBreaks.new(5),
		IncreaseWeaponsConditionCostMultiplier.new(0.5),
	]

func get_icon() -> Texture2D:
	return load("res://Art/items/broken_sword_icon_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/broken_sword_cursed_UI_desc.png")
