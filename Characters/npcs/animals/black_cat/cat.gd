@icon("res://Art/cat_black_0.png")
class_name Cat extends Animal

const CAT_SOUNDS: PackedStringArray = ["res://Audio/Sounds/cat/小次郎/1.wav", "res://Audio/Sounds/cat/小次郎/2.wav", "res://Audio/Sounds/cat/小次郎/3_amplified.wav", "res://Audio/Sounds/cat/小次郎/5_amplified.wav", "res://Audio/Sounds/cat/小次郎/6_amplified.wav"]

func _init() -> void:
	sounds = CAT_SOUNDS