extends Sprite2D

const SAW_SCENE: PackedScene = preload("res://Weapons/Saw.tscn")

@onready var timer: Timer = get_node("Timer")


func _on_timer_timeout() -> void:
	var saw: Saw = SAW_SCENE.instantiate()
	#saw.position = position
	get_parent().add_child(saw)
	saw.launch(position + Vector2.DOWN * 8, Vector2.DOWN, 100)
	timer.wait_time = randf_range(0.8, 1.5)
