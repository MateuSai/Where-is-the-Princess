class_name Candle extends Node2D

const ON_TEXTURE: Texture2D = preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/Buildings/merchant_candle.png")
const OFF_TEXTURE: Texture2D = preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/Buildings/merchant_candle_off.png")

@onready var day_night_system: DayNightSystem = get_tree().current_scene.get_node("%DayNightSystem")

@onready var light: PointLight2D = $Light
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if SavedData.get_biome_conf().day_night_cycle:
		if day_night_system.is_day():
			light.enabled = false
			sprite.texture = OFF_TEXTURE
		else:
			light.enabled = true
			sprite.texture = ON_TEXTURE

		day_night_system.day_started.connect(func() -> void:
			light.enabled=false
			sprite.texture = OFF_TEXTURE
		)
		day_night_system.night_started.connect(func() -> void:
			light.enabled=true
			sprite.texture = ON_TEXTURE
		)

