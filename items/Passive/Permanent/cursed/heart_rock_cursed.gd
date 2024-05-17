class_name HeartRockCursed extends CursedPermanentPassiveItem

var player: Player = null

func _init() -> void:
	effects = [OnRoomCleared.new([HealPlayer.new(4)]), OnRoomClosed.new([HealPlayer.new(4)])]

func get_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone-Complete.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone-Complete_UI_desc.png")
