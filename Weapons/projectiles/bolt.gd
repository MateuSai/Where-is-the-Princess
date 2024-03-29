class_name Bolt extends ArrowOrBolt

const TEXTURES: Array[Texture2D] = [preload("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Weapons/Wooden Crossbow/Bolt.png"), preload("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Weapons/Wooden Crossbow/Homing_Bolt.png"), preload("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Weapons/Wooden Crossbow/Piercing_Bolt.png"), preload("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Weapons/Wooden Crossbow/Bouncing_Bolt.png"), preload("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Weapons/Wooden Crossbow/Explosive_Bolt.png"), preload("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Weapons/Wooden Crossbow/Bolt.png")]


func _ready() -> void:
	super()

	textures = TEXTURES
