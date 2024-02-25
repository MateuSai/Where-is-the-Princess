class_name FlockSteering extends CharacterDetector

#@onready var fsm: FiniteStateMachine = $"../FiniteStateMachine"
@onready var character: Enemy = get_parent()


#func _ready() -> void:
	#super()
#
	#character.get_dir = func() -> Vector2:
		#if characters_inside.is_empty():
			#return character.navigation_agent.get_next_path_position() - character.global_position
		#else:
			#var character_with_smaller_index: Character = get_character_with_smaller_index()
#
			#if character_with_smaller_index.get_index() > character.get_index():
				#return character.navigation_agent.get_next_path_position() - character.global_position
#
			#var dir: Vector2 = character_with_smaller_index.mov_direction.normalized()
#
			#dir += _get_separation_steering()
			#dir += _get_cohesion_steering()
#
			##if fsm.state != RatFSM.IDLE and character_with_smaller_index.state_machine.state == RatFSM.IDLE:
				##fsm.set_state(RatFSM.IDLE)
#
			#return character.mov_direction.lerp(dir.normalized(), 0.15)


func _on_enemy_entered(character: Node2D) -> void:
	if not character is Rat:
		return

	super(character)


func get_character_with_smaller_index() -> Character:
	var characters_to_check: Array[Character] = characters_inside.duplicate()
	characters_to_check.push_back(character)

	var character_with_smaller_index: Character = null
	var character_with_smaller_index_index: int

	for character_in_range: Character in characters_to_check:
		if character_with_smaller_index == null or (character_with_smaller_index_index > character_in_range.get_index()):
			character_with_smaller_index = character_in_range
			character_with_smaller_index_index = character_in_range.get_index()

	return character_with_smaller_index


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

	return steering * 50
