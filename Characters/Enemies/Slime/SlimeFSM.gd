extends FiniteStateMachine

#@onready var hitbox: Hitbox = $"../Hitbox"


func _init() -> void:
	_add_state("chase")
#	_add_state("attack")
	_add_state("dead")


func _ready() -> void:
	set_state(states.chase)


func _state_logic(_delta: float) -> void:
	match state:
		states.chase:
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
#		states.attack:
#			hitbox.rotation = (parent.player.position - parent.global_position).angle()
#			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
#			if parent.mov_direction.y >= 0 and animation_player.current_animation != "attack":
#				animation_player.play("attack")
#			elif parent.mov_direction.y < 0 and animation_player.current_animation != "attack_up":
#				animation_player.play("attack_up")


func _get_transition() -> int:
#	var dis: float = (parent.player.position - parent.global_position).length()
#	match state:
#		states.chase:
#			if dis <= 10:
#				return states.attack
#		states.attack:
#			if dis > 14:
#				return states.chase
	return -1


func _enter_state(_previous_state: int, _new_state: int) -> void:
	pass
#	match new_state:
#		states.chase:
#			pass
#			animation_player.play("fly")
#		states.dead:
#			# parent.spawn_loot()
#			animation_player.play("dead")
