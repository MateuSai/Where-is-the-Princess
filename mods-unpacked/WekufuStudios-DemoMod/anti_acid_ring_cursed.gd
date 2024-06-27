class_name AntiAcidRingCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [
		IncreaseTimeBetweenAcidDamages.new(0.5),
        AddPlayerExtraDamageByEnemyType.new("acid", 1),
        EnemyDeadAcidExplosion.new()
	]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Acid_resist_ring_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Acid_resist_ring_cursed_UI_desc.png")