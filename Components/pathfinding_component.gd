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
		navigation_agent.target_position = target.global_position


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
		if navigation_agent.is_target_reached():
			navigation_agent.target_position = _get_closer_position_to_circle_target()
		elif not navigation_agent.is_target_reachable():
			rot_around_character_dir *= -1
			navigation_agent.target_position = _get_closer_position_to_circle_target()

	func _get_closer_position_to_circle_target() -> Vector2:
		return target.global_position + (character.global_position - target.global_position).rotated(rot_around_character_dir * PI/4)


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
