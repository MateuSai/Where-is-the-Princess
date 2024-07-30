class_name CliffInteractArea extends InteractArea

const DIALOGUES: Array[String] = [
	"PLAYER_ABOUT_TO_JUMP_FROM_CLIFF_1",
	"PLAYER_ABOUT_TO_JUMP_FROM_CLIFF_2",
	"PLAYER_ABOUT_TO_JUMP_FROM_CLIFF_3",
	"PLAYER_ABOUT_TO_JUMP_FROM_CLIFF_4"
]

func _ready() -> void:
	super()

	body_entered.connect(func(body: Node) -> void:
		if body is Player and not SavedData.has_completed_dialogue(DIALOGUES[0]):
			player.can_move = false
			(body as Player).start_dialogues(DIALOGUES.duplicate())
			SavedData.add_completed_dialogue(DIALOGUES[0])
			player.dialogue_finished.connect(func() -> void:
				player.can_move = true
				var dio: NPC = get_parent().get_node("CliffDiogenes/Diogenes")
				dio.dialogue_texts = ["DIOGENES_WHEN_PLAYER_ABOUT_TO_JUMP_FROM_CLIFF"]
				dio.start_dialogue()
			, CONNECT_ONE_SHOT)
	, CONNECT_ONE_SHOT)

	player_interacted.connect(func() -> void:
		SceneTransistor.start_transition_to("res://ui/cinematics/cliff_jump/cliff_jump.tscn")
	, CONNECT_ONE_SHOT)
