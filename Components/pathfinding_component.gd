class_name PathfindingComponent extends Node

var mode: Mode: set = set_mode

@onready var target: Character = Globals.player

@onready var character: Character = get_parent()
@onready var navigation_agent: NavigationAgent2D = character.get_node_or_null("NavigationAgent2D")


func _ready() -> void:
	assert(navigation_agent)

	mode = Approach.new()


func set_mode(new_mode: Mode) -> void:
	if mode:
		mode.queue_free()
	mode = new_mode
	mode.initialize(character, navigation_agent, target)
	add_child(mode)


class Mode extends Node:
	var character: Character
	var navigation_agent: NavigationAgent2D
	var target: Character

	var timer: Timer

	func _ready() -> void:
		_on_timer_timeout()

	@warning_ignore("shadowed_variable")
	func initialize(character: Character, navigation_agent: NavigationAgent2D, target: Character) -> void:
		self.character = character
		self.navigation_agent = navigation_agent
		self.target = target

	func _spawn_timer(wait_time: float = 0.2) -> void:
		timer = Timer.new()
		timer.wait_time = wait_time
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)
		timer.start()

	func _on_timer_timeout() -> void:
		pass


class Approach extends Mode:
	const ZIG_ZAG_FLAG: int = 1
	var flags: int = 0

	func _ready() -> void:
		_spawn_timer(0.4)

		super()

	func _on_timer_timeout() -> void:
		if is_instance_valid(target):
			_get_path_to_target()
		else:
			timer.stop()
			character.mov_direction = Vector2.ZERO

	func _get_path_to_target() -> void:
		var vector_to_target: Vector2 = (target.global_position - character.global_position)
		if flags & ZIG_ZAG_FLAG and vector_to_target.length() > 24:
			navigation_agent.target_position = character.global_position + vector_to_target.rotated([1, -1][randi() % 2] * PI/4)
		else:
			navigation_agent.target_position = target.global_position


class Flee extends Mode:
	func _ready() -> void:
		_spawn_timer(0.4)

		super()

	func _on_timer_timeout() -> void:
		if is_instance_valid(target):
			_get_path_to_move_away_from_target()
		else:
			timer.stop()
			character.mov_direction = Vector2.ZERO

	func _get_path_to_move_away_from_target() -> void:
		var dir: Vector2 = (character.global_position - target.global_position).normalized()
		navigation_agent.target_position = character.global_position + dir * 100


class Circle extends Mode:
	var rot_around_character_dir: int = [1, -1][randi() % 2]
#	var distance_to_character_when_rotating_around_it: int = 20

	func _ready() -> void:
		_spawn_timer(0.2)

#		super()
		navigation_agent.target_position = _get_closer_position_to_circle_target()

	func _on_timer_timeout() -> void:
		if is_instance_valid(target):
			_circle_target()
		else:
			timer.stop()
			character.mov_direction = Vector2.ZERO

	func _circle_target() -> void:
#		if navigation_agent.is_target_reached():
		navigation_agent.target_position = _get_closer_position_to_circle_target()
		#print(navigation_agent.target_position)
#		elif not navigation_agent.is_target_reachable():
#			rot_around_character_dir *= -1
#			navigation_agent.target_position = _get_closer_position_to_circle_target()

	func _get_closer_position_to_circle_target() -> Vector2:
		var new_target_position: Vector2 = target.global_position + (character.global_position - target.global_position).rotated(rot_around_character_dir * PI/4)
		#print(new_target_position)
#		var tile_position = character.room.tilemap.local_to_map(new_target_position - character.room.tilemap.global_position)
#		var tile_id = character.room.tilemap.get_cell_atlas_coords(0, tile_position)
#		var tile_data: TileData = character.room.tilemap.get_cell_tile_data(0, tile_id)
		#print(not tile_data or tile_data.get_navigation_polygon(0))
#		print((NavigationServer2D.map_get_closest_point(navigation_agent.get_navigation_map(), new_target_position) - character.global_position))
#		if (NavigationServer2D.map_get_closest_point(navigation_agent.get_navigation_map(), new_target_position) - character.global_position).length() < 4:
#			rot_around_character_dir *= -1
#			new_target_position = target.global_position + (character.global_position - target.global_position).rotated(rot_around_character_dir * PI/4)
#		print(navigation_agent.get_final_position())
#		print(navigation_agent.target_position)
#		if tile_data:
#			print(tile_data.get_navigation_polygon(0))
		var space_state: PhysicsDirectSpaceState2D = character.get_world_2d().direct_space_state
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(character.global_position, character.global_position + character.mov_direction * 8, 1 + 16) # 1 = World, 16 = Low object
		var result: Dictionary = space_state.intersect_ray(query)
#		if not tile_data or tile_data.get_navigation_polygon(0) == null:
		if not result.is_empty():
			rot_around_character_dir *= -1
			new_target_position = target.global_position + (character.global_position - target.global_position).rotated(rot_around_character_dir * PI/4)
#		else:
#			print(tile_data.get_navigation_polygon(0))
		return new_target_position


class Wander extends Mode:
	func _ready() -> void:
		_spawn_timer(0.6)

		super()

	func _on_timer_timeout() -> void:
		if is_instance_valid(target):
			_target_random_near_position()
		else:
			timer.stop()
			character.mov_direction = Vector2.ZERO

	func _target_random_near_position() -> void:
		var max_iterations: int = 10
		var iterations: int = 0

		while iterations < max_iterations:
			navigation_agent.target_position = character.global_position + Vector2(randf_range(-64, 64), randf_range(-64, 64))
			if navigation_agent.is_target_reachable():
				return

			iterations += 1

		push_error("To many iterations to determine new close random position")
