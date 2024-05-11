class_name CrocodileJoeFSM extends FiniteStateMachine

enum {
	LONG_RANGE,
	CLOSE_RANGE,
	BITE,
	DEAD,
}

enum MoveAnimationState {
	MOVE,
	MOVE_BACKWARDS,
	MOVE_UP,
	MOVE_UP_BACKWARDS,
}
var move_animation_state: MoveAnimationState = MoveAnimationState.MOVE

var tromp_died: bool = false

const DISTANCE_TO_CHANGE_RANGE: int = 16

@onready var joe: CrocodileJoe = get_parent()
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"
@onready var weapons: EnemyWeapons = $"../EnemyWeapons"
@onready var aim_component: AimComponent = $"../AimComponent"


func start() -> void:
	joe.room.enemy_died.connect(func(enemy: Enemy) -> void:
		if enemy is NecroTromp:
			tromp_died = true
	)

	set_state(LONG_RANGE)


func _state_logic(_delta: float) -> void:
	match state:
		LONG_RANGE:
			var aim_result: AimComponent.AimResult = aim_component.get_dir()
			var aim_dir: Vector2 = aim_result.dir
			weapons.move(aim_dir)
			if not weapons.is_busy():
				if weapons.current_weapon.weapon_sprite.frame == Crossbow.RELEASED_FRAME:
					weapons.reload()
				else:
					if aim_result.clear:
						if tromp_died and randi() % 5 == 0:
							weapons.active_ability()
						else:
							weapons.attack()

			joe.move_to_target()
			if aim_dir.x > 0 and joe.sprite.flip_h:
				joe._on_change_dir()
			elif aim_dir.x < 0 and not joe.sprite.flip_h:
				joe._on_change_dir()
			#joe.move()

			_update_animation(aim_dir)
		CLOSE_RANGE:
			if not animation_player.is_playing():
				var dir: Vector2 = (joe.target.global_position - joe.global_position).normalized()
				if dir.x > 0 and joe.sprite.flip_h:
					joe._on_change_dir()
				elif dir.x < 0 and not joe.sprite.flip_h:
					joe._on_change_dir()

				if dir.y >= 0:
					animation_player.play("bite")
				else:
					animation_player.play("bite_up")


func _get_transition() -> int:
	match state:
		LONG_RANGE:
			var distance_to_target: float = (joe.target.global_position - joe.global_position).length()
			if distance_to_target < DISTANCE_TO_CHANGE_RANGE:
				return CLOSE_RANGE
		CLOSE_RANGE:
			var distance_to_target: float = (joe.target.global_position - joe.global_position).length()
			if distance_to_target > DISTANCE_TO_CHANGE_RANGE:
				return LONG_RANGE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		LONG_RANGE:
			weapons.show()
			pathfinding_component.set_mode(PathfindingComponent.Wander.new())
			pathfinding_component.mode.timer.wait_time = 2
		CLOSE_RANGE:
			animation_player.stop()
			weapons.hide()
			#pathfinding_component.set_mode(PathfindingComponent.Approach.new())


func _update_animation(dir: Vector2) -> void:
	if dir.y >= 0:
		#print(dir)
		#print(joe.mov_direction)
		if ((dir.x > 0 and joe.mov_direction.x < 0) or (dir.x < 0 and joe.mov_direction.x > 0)) and (animation_player.current_animation != "move" or move_animation_state != MoveAnimationState.MOVE_BACKWARDS):
			#print("a")
			move_animation_state = MoveAnimationState.MOVE_BACKWARDS
			animation_player.play_backwards("move")
		elif ((dir.x >= 0 and joe.mov_direction.x >= 0) or (dir.x <= 0 and joe.mov_direction.x <= 0)) and (animation_player.current_animation != "move" or move_animation_state != MoveAnimationState.MOVE):
			#print("b")
			move_animation_state = MoveAnimationState.MOVE
			animation_player.play("move")
	else:
		if ((dir.x > 0 and joe.mov_direction.x < 0) or (dir.x < 0 and joe.mov_direction.x > 0)) and (animation_player.current_animation != "move_up" or move_animation_state != MoveAnimationState.MOVE_UP_BACKWARDS):
			#print("c")
			move_animation_state = MoveAnimationState.MOVE_UP_BACKWARDS
			animation_player.play_backwards("move_up")
		elif ((dir.x >= 0 and joe.mov_direction.x >= 0) or (dir.x <= 0 and joe.mov_direction.x <= 0)) and (animation_player.current_animation != "move_up" or move_animation_state != MoveAnimationState.MOVE_UP):
			#print("d")
			move_animation_state = MoveAnimationState.MOVE_UP
			animation_player.play("move_up")
