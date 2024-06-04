@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/merchant_idle_down_01.png")
class_name NPC extends StaticBody2D

const DIALOGUE_BOX_SCENE: PackedScene = preload ("res://ui/dialogue_system/dialogue_box.tscn")

const DIALOGUE_TOP_LEFT_POSITION_OFFSET: Vector2 = Vector2( - 110, -50)
const DIALOGUE_BOTTOM_LEFT_POSITION_OFFSET: Vector2 = Vector2( - 112, -2)

var dialogue_box: DialogueBox
var dialogue_tween: Tween = null

signal dialogue_finished()

@export var dialogues_in_order: bool = false
signal used_all_dialogues()
@export var dialogue_texts: PackedStringArray = ["Violence breeds violence but in the end it has to be this way", "お前はもう死んでいる", "Zeus is the son of Kronos", "Diogenes was a gigachad"]:
	set(new_dialogue_texts):
		dialogue_texts = new_dialogue_texts
		used_dialogue_texts = []
var used_dialogue_texts: PackedStringArray = []

@onready var id: String = scene_file_path.get_file().trim_suffix(".tscn").to_snake_case()
@onready var interact_area: InteractArea = $InteractArea

func _ready() -> void:
	interact_area.player_interacted.connect(_on_player_interacted)

func _on_player_interacted() -> void:
	if dialogue_box == null:
		start_dialogue()
	else:
		if dialogue_tween == null:
			dialogue_box.show_all_text()

func start_dialogue() -> void:
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	add_child(dialogue_box)

	if dialogues_in_order:
		var dialogue_text: String = dialogue_texts[used_dialogue_texts.size()]

		dialogue_box.start_displaying_text(tr(dialogue_text))
		used_dialogue_texts.push_back(dialogue_text)

		if dialogue_texts.size() == used_dialogue_texts.size():
			used_all_dialogues.emit()
	else:
		var available_dialogue_texts: PackedStringArray = dialogue_texts.duplicate()
		for i: int in range(available_dialogue_texts.size() - 1, -1, -1):
			if used_dialogue_texts.has(available_dialogue_texts[i]):
				available_dialogue_texts.remove_at(i)
		if available_dialogue_texts.is_empty():
			available_dialogue_texts = dialogue_texts.duplicate()
			used_dialogue_texts = []
		var random_dialogue_text: String = available_dialogue_texts[randi() % available_dialogue_texts.size()]
		dialogue_box.start_displaying_text(random_dialogue_text)
		used_dialogue_texts.push_back(random_dialogue_text)

	dialogue_box.finished_displaying_text.connect(func() -> void:
		dialogue_tween=create_tween()
		dialogue_tween.tween_property(dialogue_box, "modulate:a", 0.0, 1).set_delay(3)
		await dialogue_tween.finished
		dialogue_tween=null
		dialogue_box.queue_free()
		dialogue_box=null
		dialogue_finished.emit()
	)
