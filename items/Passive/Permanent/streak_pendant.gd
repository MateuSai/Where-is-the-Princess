extends PermanentArtifact

func _init() -> void:
	effects = [
		DisableOnCondition.new(
			OnPlayerDamaged.new([]),
			OnEnemyKilled.new([WeaponDamageMultiplier.new(1.2)], 3)
		)
	]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/streak_pendant.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Streak_pendant_UI_desc.png")
