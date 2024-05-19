extends PermanentPassiveItem

func _init() -> void:
	effects = [
		DisableOnCondition.new(
			OnPlayerDamaged.new([]),
			OnEnemyKilled.new([WeaponDamageMultiplier.new(1.2)], 3)
		)
	]

func get_icon() -> Texture2D:
	return load("res://Art/items/Stone_Hearth.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Stone_Hearth_UI_desc.png")