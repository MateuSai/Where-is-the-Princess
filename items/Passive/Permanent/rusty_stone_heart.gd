class_name RustyStoneHeart extends PermanentArtifact

func _init() -> void:
	effects = [OnRoomClosed.new([HealPlayer.new(1)])]

func get_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone_UI_desc.png")

func get_unite_dictionary() -> Dictionary:
	return {
		StoneHeart.new().get_script_path(): CompleteStoneHeart.new().get_script_path(),
	}
