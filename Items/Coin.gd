class_name Coin extends Area2D

@onready var player: Player = get_tree().current_scene.get_node("Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_player_entered)
	set_physics_process(false)
	# create_tween().tween_property(self, "position", position + Vector2.RIGHT * 200, 5.0)
	create_tween().tween_property(self, "position", position + Vector2.RIGHT.rotated(randf_range(0, 2 * PI)) * randf_range(10, 18), 0.5)


func _physics_process(delta: float) -> void:
	global_position += (player.position - global_position).normalized() * 20 * delta


@warning_ignore("shadowed_variable")
func _on_player_entered(player: Player) -> void:
	player.add_coin()
	queue_free()
