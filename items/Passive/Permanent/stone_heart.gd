class_name StoneHeart extends PermanentPassiveItem

func _init() -> void:
	effects = [OnRoomCleared.new([HealPlayer.new(1)])]

func get_icon() -> Texture2D:
	return load("res://Art/items/Stone_Hearth.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Stone_Hearth_UI_desc.png")

func get_unite_dictionary() -> Dictionary:
	return {
		HeartStone.new().get_script_path(): HeartRock.new().get_script_path(),
	}
