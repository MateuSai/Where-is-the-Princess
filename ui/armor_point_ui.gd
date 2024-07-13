class_name ArmorPointUI extends TextureRect

const TEXTURES: Array[Texture2D] = [preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_noarmor.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_bit.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_medium.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_UI_full.png")]

var ap: int:
	set(new_ap):
		assert(new_ap >= 0 and new_ap <= 3)
		ap = new_ap
		texture = TEXTURES[ap]


func _init() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_TILE
	custom_minimum_size = Vector2(9, 9)
	texture = TEXTURES[TEXTURES.size() - 1]
