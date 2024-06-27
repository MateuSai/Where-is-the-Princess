class_name OrbOfTheBerserkerCursed extends CursedPermanentPassiveItem

var damage_increased: bool = false

func _init() -> void:
	effects = [OnHpLessThan.new(2, [WeaponDamageMultiplier.new(3)])]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/beherit_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Beherit_cursed_UI_desc.png")
