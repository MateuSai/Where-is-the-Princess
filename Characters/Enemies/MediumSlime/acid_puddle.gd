## The acid progress is applied on the Character class
class_name AcidPuddle extends Area2D


static var characters_inside: Array[Dictionary] = []


@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	sprite.frame_coords.y = randi() % sprite.vframes

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	animation_player.play("spawn")
	await animation_player.animation_finished
	animation_player.play("puddle")
	animation_player.seek(randf_range(0, 4), true)


func _on_body_entered(body: Node2D) -> void:
	assert(body is Character)

	var character: Character = body

	if character.has_resistance(Character.Resistance.ACID):
		return

	var character_dic: Dictionary = _get_character_dic(body)
	if character_dic.is_empty():
		characters_inside.push_back({
			object = body,
			count = 1,
		})
		character.start_progressing_acid()
	else:
		character_dic.count += 1


func _on_body_exited(body: Node2D) -> void:
	assert(body is Character)

	var character: Character = body

	if character.has_resistance(Character.Resistance.ACID):
		return

	var character_dic: Dictionary = _get_character_dic(body)

	if not character_dic.is_empty():
		character_dic.count -= 1
		if character_dic.count == 0:
			characters_inside.erase(character_dic)
			character.stop_progressing_acid()


func _get_character_dic(body: Node2D) -> Dictionary:
	for dic: Dictionary in characters_inside:
		if dic.object == body:
			return dic

	return {}
