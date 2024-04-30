class_name AggressionSpellCursed extends CursedPermanentPassiveItem

var player: Player = null
var damage_doubled: bool = false

func _init() -> void:
	effects = [
		OnFullHP.new([
			WeaponDamageMultiplier.new(2.0),
			OnEnemyDamaged.new([DamagePlayerIgnoringArmor.new(2)])
		])
	]

func get_icon() -> Texture2D:
	return load("res://Art/items/Agression_spell.png")
