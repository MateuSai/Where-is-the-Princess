class_name StartPlayerDialogueArea extends Area2D


@export_multiline var dialogue: String = ""
var dialogue_displayed: bool = false


func _init() -> void:
	collision_layer = 0
	collision_mask = 2

	body_entered.connect(func(body: Node2D) -> void:
		if body is Player and not dialogue_displayed:
			dialogue_displayed = true
			(body as Player).start_dialogue(dialogue)
			is_queued_for_deletion()
	)
