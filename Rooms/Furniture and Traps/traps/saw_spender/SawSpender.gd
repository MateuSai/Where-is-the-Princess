extends Sprite2D

const SAW_SCENE: PackedScene = preload ("res://Weapons/projectiles/Saw.tscn")

@onready var timer: Timer = get_node("Timer")

func _ready() -> void:
	var room: DungeonRoom = owner
	room.closed.connect(func() -> void: timer.start())
	room.cleared.connect(func() -> void: timer.stop())

func _on_timer_timeout() -> void:
	var saw: Saw = SAW_SCENE.instantiate()
	#saw.position = position
	get_parent().add_child(saw)
	saw.launch(position + Vector2.DOWN * 8, Vector2.DOWN, 100)
	timer.wait_time = randf_range(0.5, 1.0)
