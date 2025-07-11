class_name SoulItem extends Area2D


var acc: Vector2 = Vector2.ZERO

@onready var player: Player = Globals.player

@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_player_entered)
	if player.attract_souls_even_on_combat:
		set_physics_process(true)
	else:
		set_physics_process(false)
		# create_tween().tween_property(self, "position", position + Vector2.RIGHT * 200, 5.0)
		create_tween().tween_property(self, "position", position + Vector2.RIGHT.rotated(randf_range(0, 2 * PI)) * randf_range(10, 18), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _physics_process(delta: float) -> void:
	acc += (player.position - global_position).normalized() * 800 * delta
	global_position += acc * delta
	acc = acc.lerp(Vector2.ZERO, 0.1)


func go_to_player() -> void:
	set_physics_process(true)


@warning_ignore("shadowed_variable")
func _on_player_entered(player: Player) -> void:
	set_physics_process(false)
	if player.weapons.can_current_weapon_pick_up_soul():
		collision_shape.free()
		player.weapons.add_soul_to_current_weapon()
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(self, "position", position + Vector2.UP * 8, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.finished.connect(queue_free)
