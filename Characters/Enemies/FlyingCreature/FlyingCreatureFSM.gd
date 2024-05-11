extends FiniteStateMachine

enum {
	CHASE,
	ATTACK,
	DEAD,
}

@onready var enemy: Enemy = get_parent()

@onready var hitbox: Hitbox = $"../Hitbox"


func start() -> void:
	set_state(CHASE)


func _state_logic(_delta: float) -> void:
	match state:
		CHASE:
			enemy.move_to_target()
			#parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "fly":
				animation_player.play("fly")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "fly_up":
				animation_player.play("fly_up")
		ATTACK:
			hitbox.rotation = (enemy.target.position - parent.global_position).angle()
			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "attack":
				animation_player.play("attack")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "attack_up":
				animation_player.play("attack_up")


func _get_transition() -> int:
	var dis: float = (enemy.target.position - parent.global_position).length()
	match state:
		CHASE:
			if dis <= 10:
				return ATTACK
		ATTACK:
			if dis > 14:
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
#			animation_player.play("dead")
