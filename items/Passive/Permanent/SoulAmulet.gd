class_name SoulAmulet extends PermanentArtifact

func _init() -> void:
	effects = [AttractSoulsEvenOnCombat.new()]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/soul_amulet.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Soul_amulet_UI_desc.png")
