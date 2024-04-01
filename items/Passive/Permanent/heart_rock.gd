class_name HeartRock extends PermanentPassiveItem

var player: Player = null


func _init() -> void:
	effects = [RecoverHpOnRoomClosed.new(2), RecoverHpOnRoomCleared.new(2)]


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/mole/stone_proyectile.png")


func get_big_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone-Complete_UI_desc.png")
