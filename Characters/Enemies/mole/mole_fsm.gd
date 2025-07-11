class_name MoleFSM extends FiniteStateMachine

enum {
	ABOVE,
	BELOW,
	DEAD,
}

@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"
@onready var go_underground_timer: Timer = $"../GoUndergroundTimer"


func _state_logic(_delta: float) -> void:
	if state == ABOVE:
		if not animation_player.current_animation.begins_with("come_out"):
			var vector_to_player: Vector2 = parent.player.position - parent.global_position
			if vector_to_player.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif vector_to_player.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")
			if vector_to_player.x >= 0 and sprite.flip_h:
				sprite.flip_h = false
			elif vector_to_player.x < 0 and not sprite.flip_h:
				sprite.flip_h = true
#		parent.move_to_target()
#		parent.move()
#		if parent.mov_direction.y >= 0 and animation_player.current_animation != "fly":
#			animation_player.play("fly")
#		elif parent.mov_direction.y < 0 and animation_player.current_animation != "fly_up":
#			animation_player.play("fly_up")


func _get_transition() -> int:
	match state:
		ABOVE:
			if go_underground_timer.is_stopped():
				return BELOW
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		ABOVE:
			collision_shape.set_deferred("disabled", false)
			parent.come_out()
			#animation_player.play("fly")
			parent.attack_timer.start(randf_range(0.4, 0.8))
			go_underground_timer.start(randf_range(3.0, 5.0))
			var vector_to_player: Vector2 = parent.player.position - parent.global_position
			if vector_to_player.y >= 0:
				animation_player.play("come_out")
			else:
				animation_player.play("come_out_up")
			if vector_to_player.x >= 0 and sprite.flip_h:
				sprite.flip_h = false
			elif vector_to_player.x < 0 and not sprite.flip_h:
				sprite.flip_h = true
		BELOW:
			collision_shape.set_deferred("disabled", true)
			var vector_to_player: Vector2 = parent.player.position - parent.global_position
			if vector_to_player.y >= 0:
				animation_player.play_backwards("come_out")
			else:
				animation_player.play_backwards("come_out_up")
			parent.velocity = Vector2.ZERO
			parent.mov_direction = Vector2.ZERO
			await animation_player.animation_finished
			parent.hide()
			await get_tree().create_timer(randf_range(0.7, 2.4), false).timeout
			set_state(ABOVE)
		DEAD:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		ABOVE:
			go_underground_timer.stop()
			parent.attack_timer.stop()
