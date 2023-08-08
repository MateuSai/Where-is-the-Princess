extends FiniteStateMachine

@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"
@onready var go_underground_timer: Timer = $"../GoUndergroundTimer"


func _init() -> void:
	_add_state("above")
	_add_state("below")
	_add_state("dead")


func _state_logic(_delta: float) -> void:
	if state == states.above:
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
#		parent.chase()
#		parent.move()
#		if parent.mov_direction.y >= 0 and animation_player.current_animation != "fly":
#			animation_player.play("fly")
#		elif parent.mov_direction.y < 0 and animation_player.current_animation != "fly_up":
#			animation_player.play("fly_up")


func _get_transition() -> int:
	match state:
		states.above:
			if go_underground_timer.is_stopped():
				return states.below
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.above:
			collision_shape.set_deferred("disabled", false)
			parent.come_out()
			#animation_player.play("fly")
			parent.attack_timer.start(randf_range(0.4, 0.8))
			go_underground_timer.start(randf_range(1.3, 2.8))
			var vector_to_player: Vector2 = parent.player.position - parent.global_position
			if vector_to_player.y >= 0:
				animation_player.play("come_out")
			else:
				animation_player.play("come_out_up")
			if vector_to_player.x >= 0 and sprite.flip_h:
				sprite.flip_h = false
			elif vector_to_player.x < 0 and not sprite.flip_h:
				sprite.flip_h = true
		states.below:
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
			set_state(states.above)
		states.dead:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		states.above:
			go_underground_timer.stop()
			parent.attack_timer.stop()
