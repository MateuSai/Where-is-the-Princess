class_name NPC extends StaticBody2D

const DIALOGUE_BOX_SCENE: PackedScene = preload("res://ui/dialogue_system/dialogue_box.tscn")

var dialogue_box: DialogueBox

@onready var interact_area: InteractArea = $InteractArea


func _ready() -> void:
	interact_area.player_interacted.connect(func():
		if dialogue_box == null:
			dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
			add_child(dialogue_box)
			dialogue_box.start_displaying_text("Violence breeds violence but in the end it has to be this way")
			dialogue_box.finished_displaying_text.connect(func():
				await get_tree().create_timer(4, false).timeout
				dialogue_box.queue_free()
				dialogue_box = null
			)
	)
