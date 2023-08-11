extends Camera2D

var flash_tween: Tween

@onready var flash_sprite: Sprite2D = $FlashSprite


func _ready() -> void:
	flash_sprite.modulate.a = 0.0


func flash() -> void:
	if not flash_tween:
		flash_tween = create_tween()
		flash_tween.tween_property(flash_sprite, "modulate:a", 0.6, 0.1)
		flash_tween.tween_property(flash_sprite, "modulate:a", 0.0, 0.1)
		flash_tween.set_loops(3)
		await flash_tween.finished
		flash_tween = null
