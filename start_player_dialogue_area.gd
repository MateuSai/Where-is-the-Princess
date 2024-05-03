class_name StartPlayerDialogueArea extends Area2D

@export_multiline var dialogues: Array[String] = []
@export var one_time_dialogue: bool = true

func _ready() -> void:
	assert(not dialogues.is_empty())

	collision_layer = 0
	collision_mask = 2

	if SavedData.data.has_completed_dialogue(dialogues[0]):
		queue_free()

	body_entered.connect(func(body: Node2D) -> void:
		if body is Player and not is_queued_for_deletion():
			(body as Player).start_dialogues(dialogues)
			if one_time_dialogue:
				SavedData.add_completed_dialogue(dialogues[0])
			queue_free()
	)
