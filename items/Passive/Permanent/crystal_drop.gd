class_name CrystalDrop extends PermanentArtifact

func _init() -> void:
	effects = [PlayerExtraWaterDamage.new( - 1)]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Crystal_drop.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Crystal_drop_UI_desc.png")
