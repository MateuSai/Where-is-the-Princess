class_name AimComponent extends Node

const FLAG_PREDICT_TRAJECTORY: int = 1
@export_flags("predict_trajectory") var flags: int = 0

@onready var character: Character = get_parent()


func get_dir() -> Vector2:
	return (character.target.global_position - character.global_position).normalized()
