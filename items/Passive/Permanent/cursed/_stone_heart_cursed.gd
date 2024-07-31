class_name StoneHeartCursed extends CursedPermanentArtifact

func _init() -> void:
	effects = [OnRoomCleared.new([HealPlayer.new(2), DamagePlayerArmor.new(1)])]

func get_icon() -> Texture2D:
	return load("res://Art/items/Stone_Hearth.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Stone_Hearth_UI_desc.png")

func get_unite_dictionary() -> Dictionary:
	return {
		HeartStoneCursed.new().get_script_path(): HeartRockCursed.new().get_script_path(),
	}
