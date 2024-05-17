class_name HeartStoneCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [OnRoomClosed.new([HealPlayer.new(2), DamagePlayerArmor.new(1)])]

func get_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone_UI_desc.png")

func get_unite_dictionary() -> Dictionary:
	return {
		StoneHeartCursed.new().get_script_path(): HeartRockCursed.new().get_script_path(),
	}
