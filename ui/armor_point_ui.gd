class_name ArmorPointUI extends TextureRect

const TEXTURES: Array[Array] = [
	[preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_bit_empty.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_bit_full.png")],

	[preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_medium_empty.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_medium_half.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_medium_full.png")],

	[preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_zero.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_bit.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_medium.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_full.png")]
]


var ap: int:
	set(new_ap):
		assert(new_ap >= 0 and new_ap <= 3)
		ap = new_ap
		texture = TEXTURES[max_ap - 1][ap]
var max_ap: int


func _init() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_TILE
	custom_minimum_size = Vector2(8, 9)
	#texture = TEXTURES[TEXTURES.size() - 1]
