class_name AntiAcidRing extends PermanentArtifact

func _init() -> void:
	effects = [
		IncreaseTimeBetweenAcidDamages.new(0.3)
	]

func get_cursed_version_path() -> String:
	return "res://mods-unpacked/WekufuStudios-DemoMod/anti_acid_ring_cursed.gd"

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Acid_resist_ring.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Acid_resist_ring_UI_desc.png")
