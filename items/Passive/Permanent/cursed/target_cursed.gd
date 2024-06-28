class_name TargetCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [IncreaseThrowPiercing.new(2), IncreaseThrowSpread.new(0.3)]

func get_icon() -> Texture2D:
	return load("res://Art/items/Bolt_icon_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Bolt_UI_cursed_desc.png")
