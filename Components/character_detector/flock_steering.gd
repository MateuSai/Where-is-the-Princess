class_name FlockSteering extends CharacterDetector

@onready var character: Enemy = get_parent()


func _ready() -> void:
	super()

	character.get_dir = func() -> Vector2:
		if characters_inside.is_empty():
			return character.navigation_agent.get_next_path_position() - character.global_position
		else:
			var character_with_smaller_index: Character = null
			var character_with_smaller_index_index: int

			for character_in_range: Character in characters_inside:
				if character_with_smaller_index == null or (character_with_smaller_index_index > character_in_range.get_index()):
					character_with_smaller_index = character_in_range
					character_with_smaller_index_index = character_in_range.get_index()

			assert(character_with_smaller_index)

			if character_with_smaller_index_index > character.get_index():
				return character.navigation_agent.get_next_path_position() - character.global_position

			var dir: Vector2 = character_with_smaller_index.mov_direction.normalized()

			dir += _get_separation_steering()
			dir += _get_cohesion_steering()

			return character.mov_direction.lerp(dir.normalized(), 0.15)


func _get_separation_steering() -> Vector2:
	var steering: Vector2 = Vector2.ZERO

	for character_in_range: Character in characters_inside:
		steering += character.global_position - character_in_range.global_position

	return steering.normalized() * 0.1


func _get_cohesion_steering() -> Vector2:
	var steering: Vector2 = Vector2.ZERO
	var center_pos: Vector2 = global_position

	for character_in_range: Character in characters_inside:
		center_pos += character_in_range.global_position

	center_pos /= characters_inside.size()

	steering = (center_pos - character.global_position).normalized()

	return steering * 0.2
