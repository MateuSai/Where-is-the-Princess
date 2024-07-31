class_name CompleteStoneHeart extends PermanentArtifact

func _init() -> void:
	effects = [OnRoomCleared.new([RepairArmor.new(2)]), OnRoomClosed.new([HealPlayer.new(2)])]

func get_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone-Complete.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone-Complete_UI_desc.png")
