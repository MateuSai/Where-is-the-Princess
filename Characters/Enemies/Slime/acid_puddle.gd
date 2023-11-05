class_name AcidPuddle extends Area2D


static var characters_inside: Array[Dictionary] = []


@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.frame_coords.y = randi() % sprite.vframes


func _on_body_entered(body: Node2D) -> void:
	assert(body is Character)

	var character_dic: Dictionary = _get_character_dic(body)
	if character_dic.is_empty():
		characters_inside.push_back({
			object = body,
			count = 1,
		})
	else:
		character_dic.count += 1


func _on_body_exited(body: Node2D) -> void:
	assert(body is Character)

	var character_dic: Dictionary = _get_character_dic(body)
	assert(not character_dic.is_empty())

	character_dic.count -= 1
	if character_dic.count == 0:
		characters_inside.erase(character_dic)


func _get_character_dic(body: Node2D) -> Dictionary:
	for dic in characters_inside:
		if dic.object == body:
			return dic

	return {}
