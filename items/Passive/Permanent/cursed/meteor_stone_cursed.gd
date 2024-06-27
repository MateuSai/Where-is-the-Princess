class_name MeteorStoneCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [ArmorAbilityRechargeTimeReduction.new(0.6), ArmorShardBreakProbability.new(30)]

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/meteoric_stone_cursed.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/meteoric_stone_cursed_UI_desc.png")