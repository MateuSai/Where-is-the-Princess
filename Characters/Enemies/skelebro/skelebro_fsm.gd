class_name SkelebroFSM extends FiniteStateMachine

enum {
	CHASE,
	ATTACK,
	DEAD,
}

#@onready var hitbox: Hitbox = $"../Hitbox"


func start() -> void:
	set_state(CHASE)


func _state_logic(_delta: float) -> void:
	match state:
		CHASE:
			parent.move_to_target()
			#parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
		ATTACK:
#			hitbox.rotation = (parent.player.position - parent.global_position).angle()
#			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")


func _get_transition() -> int:
	var dis: float = (parent.player.position - parent.global_position).length()
	match state:
		CHASE:
			if dis <= 20:
				return ATTACK
		ATTACK:
			if dis > 28:
				return CHASE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		CHASE:
			pass
#			animation_player.play("fly")
		ATTACK:
			(parent as Enemy).mov_direction = Vector2.ZERO
		DEAD:
			pass
			# parent.spawn_loot()
#			animation_player.play("dead")
