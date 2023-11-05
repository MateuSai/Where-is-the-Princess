class_name Slime extends Enemy


const ACID_PUDDLE_SCENE: PackedScene = preload("res://Characters/Enemies/Slime/acid_puddle.tscn")

@onready var spawn_puddle_timer: Timer = $SpawnPuddleTimer


func _ready() -> void:
	super()

	spawn_puddle_timer.timeout.connect(_spawn_puddle)

	target_random_near_position()


func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		target_random_near_position()
	else:
		path_timer.stop()
		mov_direction = Vector2.ZERO


func _spawn_puddle() -> void:
	var acid_puddle: AcidPuddle = ACID_PUDDLE_SCENE.instantiate()
	room.add_child(acid_puddle)
	acid_puddle.position = position - acid_puddle.sprite.position
