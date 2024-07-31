class_name OrbOfTheBerserker extends PermanentArtifact

var damage_increased: bool = false

func _init() -> void:
	effects = [OnHpLessThan.new(4, [WeaponDamageMultiplier.new(2)])]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/beherit.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Beherit_UI_desc.png")
