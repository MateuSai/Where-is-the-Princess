class_name BiggerRations extends PermanentArtifact

func _init() -> void:
	effects = [IncreaseFoodExtraHp.new(1)]

func get_icon() -> Texture2D:
	return load("res://Art/items/big_ration_icon.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/big_ration_UI_desc.png")
