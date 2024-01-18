extends StaticBody2D

const RUINED_TEXTURE: CanvasTexture = preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/Buildings/hut_ruined.tres")

@onready var sprite: Sprite2D = $Sprite2D
@onready var shop: Node2D = $BaseCampPlayerUpgradesShop


func _ready() -> void:
	if not SavedData.data.player_upgrades_shop_unlocked:
		sprite.texture = RUINED_TEXTURE
		shop.queue_free()
