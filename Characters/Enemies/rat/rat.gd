class_name Rat extends Enemy


func _ready() -> void:
	super()

	var possible_textures: Array[Texture] = [load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Rat/Rat.png"), load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Rat/Rat_02.png"), load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Rat/Rat_03.png")]
	sprite.texture = possible_textures[randi() % possible_textures.size()]
