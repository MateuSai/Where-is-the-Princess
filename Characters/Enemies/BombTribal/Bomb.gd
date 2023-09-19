class_name Bomb extends Area2D

var reflected: bool = false

var dir: Vector2
var speed: float

@onready var bomb_parabola: BombParabola = owner


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	set_physics_process(false)


func _physics_process(delta: float) -> void:
	position += dir * speed * delta


@warning_ignore("shadowed_variable")
func hit(dir: Vector2, force: float) -> void:
	if reflected:
		return

	reflected = true

	self.dir = dir
	self.speed = force

	var g_pos: Vector2 = global_position
	var tree: SceneTree = get_tree()
	var path_follow: PathFollow2D = get_parent()

	path_follow.call_deferred("remove_child", self)
	await get_tree().process_frame
	bomb_parabola.queue_free()
	tree.current_scene.add_child(self)
	position = g_pos

	set_physics_process(true)


func destroy() -> void:
	if is_instance_valid(bomb_parabola):
		bomb_parabola.queue_free()
	else:
		queue_free()


func _on_body_entered(_body: Node2D) -> void:
	set_physics_process(false)
