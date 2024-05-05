class_name TrompFSM extends FiniteStateMachine

enum {
	ATTACK_IDLE,
	ATTACK_FLEE,
	DEAD,
}

enum MoveAnimationState {
	MOVE,
	MOVE_BACKWARDS,
	MOVE_UP,
	MOVE_UP_BACKWARDS,
}
var move_animation_state: MoveAnimationState = MoveAnimationState.MOVE

var vec_to_target: Vector2

@onready var tromp: NecroTromp = get_parent()
@onready var weapons: EnemyWeapons = $"../EnemyWeapons"
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"
#@onready var attack_timer: Timer = $"../AttackTimer"


func start() -> void:
	set_state(ATTACK_IDLE)


func _state_logic(_delta: float) -> void:
	vec_to_target = tromp.target.global_position - tromp.global_position

	if state != DEAD:
		if not weapons.is_busy():
			if not tromp.bald:
				if (weapons.current_weapon as NecromancerScepter).num_skeletons_alive < NecromancerScepter.MAX_NUM_SKELETONS_ALIVE and randi() % 2:
					weapons.attack()
				else:
					weapons.active_ability()
			else:
				if randi() % 2:
					weapons.strong_attack()
				elif (weapons.current_weapon as NecromancerScepter).num_skeletons_alive < NecromancerScepter.MAX_NUM_SKELETONS_ALIVE and randi() % 2:
					weapons.attack()
				else:
					weapons.active_ability()

	if state == ATTACK_IDLE:
		if vec_to_target.y >= 0 and animation_player.current_animation != "idle":
			animation_player.play("idle")
		elif vec_to_target.y < 0 and animation_player.current_animation != "idle_up":
			animation_player.play("idle_up")

		if vec_to_target.x > 0 and tromp.sprite.flip_h:
			tromp._on_change_dir()
		elif vec_to_target.x < 0 and not tromp.sprite.flip_h:
			tromp._on_change_dir()
	elif state == ATTACK_FLEE:
		tromp.move_to_target()
		#tromp.move()

		_update_animation(vec_to_target.normalized())


func _get_transition() -> int:
	match state:
		ATTACK_IDLE:
			if vec_to_target.length() < 24:
				return ATTACK_FLEE
		ATTACK_FLEE:
			if vec_to_target.length() > 50:
				return ATTACK_IDLE

	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		ATTACK_FLEE:
			pathfinding_component.set_mode(PathfindingComponent.Flee.new())


func _update_animation(dir: Vector2) -> void:
	if dir.y >= 0:
		#print(dir)
		#print(tromp.mov_direction)
		if ((dir.x > 0 and tromp.mov_direction.x < 0) or (dir.x < 0 and tromp.mov_direction.x > 0)) and (animation_player.current_animation != "move" or move_animation_state != MoveAnimationState.MOVE_BACKWARDS):
			#print("a")
			move_animation_state = MoveAnimationState.MOVE_BACKWARDS
			animation_player.play_backwards("move")
		elif ((dir.x >= 0 and tromp.mov_direction.x >= 0) or (dir.x <= 0 and tromp.mov_direction.x <= 0)) and (animation_player.current_animation != "move" or move_animation_state != MoveAnimationState.MOVE):
			#print("b")
			move_animation_state = MoveAnimationState.MOVE
			animation_player.play("move")
	else:
		if ((dir.x > 0 and tromp.mov_direction.x < 0) or (dir.x < 0 and tromp.mov_direction.x > 0)) and (animation_player.current_animation != "move_up" or move_animation_state != MoveAnimationState.MOVE_UP_BACKWARDS):
			#print("c")
			move_animation_state = MoveAnimationState.MOVE_UP_BACKWARDS
			animation_player.play_backwards("move_up")
		elif ((dir.x >= 0 and tromp.mov_direction.x >= 0) or (dir.x <= 0 and tromp.mov_direction.x <= 0)) and (animation_player.current_animation != "move_up" or move_animation_state != MoveAnimationState.MOVE_UP):
			#print("d")
			move_animation_state = MoveAnimationState.MOVE_UP
			animation_player.play("move_up")
