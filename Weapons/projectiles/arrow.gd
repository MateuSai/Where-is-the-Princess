@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/arrow.png")
class_name Arrow extends ArrowOrBolt

const TEXTURES: Array[Texture2D] = [ preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/arrow.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/homing_arrow.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/piercing_arrow.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/bouncing_arrow.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/explosive_arrow.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/arrow.png")]

func _ready() -> void:
	super()

	textures = TEXTURES
