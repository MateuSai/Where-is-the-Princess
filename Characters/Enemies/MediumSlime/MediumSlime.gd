class_name Slime extends Enemy


@export var acid_puddle_scene: PackedScene = load("res://Characters/Enemies/MediumSlime/acid_puddle.tscn")
@export var child_slime_scene: PackedScene = null

@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
var mode: Mode = -1
enum Mode {
	WANDER,
	CIRCLE,
}

@onready var spawn_puddle_timer: Timer = $SpawnPuddleTimer


func _ready() -> void:
	if mode == -1:
		@warning_ignore("int_as_enum_without_cast")
		mode = randi() % Mode.size()

	super()

	spawn_puddle_timer.timeout.connect(_spawn_puddle)

#	target_random_near_position()


#func _on_PathTimer_timeout() -> void:
#	if is_instance_valid(player):
#		_get_path_to_player()
#	else:
#		path_timer.stop()
#		mov_direction = Vector2.ZERO


func _spawn_puddle() -> void:
	var acid_puddle: AcidPuddle = acid_puddle_scene.instantiate()
	room.add_child(acid_puddle)
	acid_puddle.position = position - acid_puddle.sprite.position


func _duplicate_slime() -> void:
	if child_slime_scene:
		var impulse_direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0, 2*PI))
		_spawn_slime(impulse_direction)
		_spawn_slime(impulse_direction * -1)


func _spawn_slime(direction: Vector2) -> void:
	var slime: Enemy = child_slime_scene.instantiate()
	slime.mode = (mode - 1) * -1
	slime.position = position + direction * collision_shape.shape.radius
	room.add_enemy(slime)
	slime.velocity += direction * 40


func _on_died_0_5_seconds_later() -> void:
	_duplicate_slime()

	super()
