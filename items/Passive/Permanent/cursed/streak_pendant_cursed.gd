class_name StreakPendantCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [
		DisableOnCondition.new(
			OnPlayerDamaged.new([]),
			OnEnemyKilled.new([WeaponDamageMultiplier.new(1.4)], 4)
		),
		PlayerExtraDamageTaken.new(1)
	]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/streak_pendant_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Streak_pendant_cursed_UI_desc.png")
