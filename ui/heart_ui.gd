class_name HeartUI extends TextureRect

const ANIMATIONS: Array[Array] = [
	[preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_1-4_0_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_1-4_1_animation.tres")],

	[preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_2-4_0_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_2-4_1_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_2-4_2_animation.tres")],

	[preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_3-4_0_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_3-4_1_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_3-4_2_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_3-4_3_animation.tres")],

	[preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_4-4_0_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_4-4_1_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_4-4_2_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_4-4_3_animation.tres"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/heart_smol_4-4_4_animation.tres")]
]
#const TEXTURES: Array[Texture] = [preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/Heart_smol_0-4_anim_01.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/Heart_smol_1-4_anim_01.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/Heart_smol_2-4_anim_01.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/Heart_smol_3-4_anim_01.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart smol anim_01.png")]

var hp: int:
	set(new_hp):
		assert(new_hp >= 0 and new_hp <= 4)
		hp = new_hp
		texture = ANIMATIONS[max_hp - 1][hp]
var max_hp: int


func _init() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_TILE
	custom_minimum_size = Vector2(9, 9)
	#texture = TEXTURES[4]
