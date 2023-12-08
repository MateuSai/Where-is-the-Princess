class_name Rat extends Enemy


const BITE_EFFECT_SCENE: PackedScene = preload("res://Characters/Enemies/BiteEffect.tscn")

@onready var hitbox_col: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	super()

	var possible_textures: Array[Texture] = [load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Rat/Rat.png"), load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Rat/Rat_02.png"), load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Rat/Rat_03.png")]
	sprite.texture = possible_textures[randi() % possible_textures.size()]


func _spawn_bite_effect() -> void:
	var effect: Sprite2D = BITE_EFFECT_SCENE.instantiate()
	effect.global_position = hitbox_col.global_position
	get_tree().current_scene.add_child(effect)
