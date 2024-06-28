class_name AcidBootsCursed extends CursedPermanentPassiveItem

var player: Player

const ACID_PUDDLE_SCENE: PackedScene = preload ("res://Characters/Enemies/medium_slime/acid_puddle.tscn")

func _init() -> void:
	effects = [
		IncreasePlayerAcidProgressPerSecond.new( - 0.2),
		OnDashed.new([
			SpawnSceneAtPlayerPosition.new(
				ACID_PUDDLE_SCENE,
				14.0,
				Player.DASH_TIME * 2.5,
				0.008
			),
			OnChance.new(15, [
				DamagePlayer.new(1)
			])
		])
	]

func get_icon() -> Texture2D:
	return load("res://Art/items/boots_acid_icon_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/boots_acid_cursed_UI_desc.png")
