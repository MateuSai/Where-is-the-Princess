class_name BombDropper extends Sprite2D


const BOMB_VERTICAL_DROP_SCENE: PackedScene = preload("res://Weapons/projectiles/bombs/bomb_vertical_drop.tscn")

@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	self_modulate.a = 0.0


func activate() -> void:
	if cooldown_timer.is_stopped():
		var bomb_vertical_drop: BombVerticalDrop = BOMB_VERTICAL_DROP_SCENE.instantiate()
		bomb_vertical_drop.position = position + Vector2(randf_range(-5, 5), randf_range(-5, 5))
		get_parent().call_deferred("add_child", bomb_vertical_drop)
		bomb_vertical_drop.call_deferred("start")

		cooldown_timer.start()
