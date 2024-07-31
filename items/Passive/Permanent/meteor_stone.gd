class_name MeteorStone extends PermanentArtifact

func _init() -> void:
	effects = [ArmorAbilityRechargeTimeReduction.new(0.4)]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/meteoric_stone.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/meteoric_stone_UI_desc.png")
