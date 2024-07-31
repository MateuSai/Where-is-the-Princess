class_name BiggerRationsCursed extends CursedPermanentArtifact

func _init() -> void:
	effects = [
		IncreaseFoodExtraHp.new(2),
		IncreasePlayerMaxSpeed.new( - 30)
	]

func get_icon() -> Texture2D:
	return load("res://Art/items/big_ration_icon_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/big_ration_cursed_UI_desc.png")
