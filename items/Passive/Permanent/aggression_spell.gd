class_name AggressionSpell extends PermanentPassiveItem

var player: Player = null
var damage_doubled: bool = false

func _init() -> void:
	effects = [
		OnFullHP.new([
			WeaponDamageMultiplier.new(1.5),
			OnEnemyDamaged.new([DamagePlayerIgnoringArmor.new(1)])
		])
	]

func get_icon() -> Texture2D:
	return load("res://Art/items/Agression_spell.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Agression_spell_UI_desc.png")
