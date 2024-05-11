extends FiniteStateMachine

enum {
	CHASE,
	ATTACK,
	DEAD,
}


@onready var hitbox: Hitbox = $"../Hitbox"


func start() -> void:
	set_state(CHASE)


func _state_logic(_delta: float) -> void:
	match state:
		CHASE:
			parent.move_to_target()
			#parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "walk":
				animation_player.play("walk")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "walk_up":
				animation_player.play("walk_up")
		ATTACK:
			hitbox.rotation = (parent.player.position - parent.global_position).angle()
			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "attack":
				animation_player.play("attack")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "attack_up":
				animation_player.play("attack_up")


func _get_transition() -> int:
	var dis: float = (parent.player.position - parent.global_position).length()
	match state:
		CHASE:
			if dis <= 16:
				return ATTACK
		ATTACK:
			if dis > 16:
				return CHASE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		CHASE:
			pass
			#animation_player.play("fly")
		DEAD:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")
