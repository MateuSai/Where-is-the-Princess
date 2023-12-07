class_name FlockSteering extends CharacterDetector

@onready var character: Enemy = get_parent()


func _ready() -> void:
	super()

	character.get_dir = func() -> Vector2:
		var dir: Vector2 = character.navigation_agent.get_next_path_position() - character.global_position

		dir += _get_separation_steering()
		dir += _get_cohesion_steering()

		return dir


func _get_separation_steering() -> Vector2:
	var steering: Vector2 = Vector2.ZERO

	for character_in_range: Character in characters_inside:
		steering += character.global_position - character_in_range.global_position

	return steering


func _get_cohesion_steering() -> Vector2:
	var steering: Vector2 = Vector2.ZERO

	for character_in_range: Character in characters_inside:
		steering += character_in_range.global_position - character.global_position

	return steering
