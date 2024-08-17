@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/merchant_idle_down_01.png")
class_name NPC extends StaticBody2D

const DIALOGUE_BOX_SCENE: PackedScene = preload ("res://ui/dialogue_system/dialogue_box.tscn")

const DIALOGUE_TOP_LEFT_POSITION_OFFSET: Vector2 = Vector2( - 110, -20)
const DIALOGUE_TOP_RIGHT_POSITION_OFFSET: Vector2 = Vector2(0, -20)
const DIALOGUE_BOTTOM_LEFT_POSITION_OFFSET: Vector2 = Vector2( - 112, -2)

var dialogue_box: DialogueBox
var dialogue_tween: Tween = null

signal dialogue_finished()

@export var dialogues_in_order: bool = false
@export var can_interact: bool = true
signal used_all_dialogues()
@export var dialogue_texts: PackedStringArray = []:
	set(new_dialogue_texts):
		dialogue_texts = new_dialogue_texts
		used_dialogue_texts = []
var used_dialogue_texts: PackedStringArray = []

var room: DungeonRoom

@onready var id: String = scene_file_path.get_file().trim_suffix(".tscn").to_snake_case()
@onready var interact_area: InteractArea = $InteractArea

func _ready() -> void:
	var i: int = 0
	var parent: Node = self
	while i < 5:
		parent = parent.get_parent()
		if parent is DungeonRoom:
			room = parent
			break
		i += 1

	if room:
		room.npcs.push_back(self)
		tree_exiting.connect(room.npcs.erase.bind(self))

	if can_interact:
		interact_area.player_interacted.connect(_on_player_interacted)
	else:
		interact_area.queue_free()

	if SavedData.data.is_npc_killed(id):
		queue_free()

func _on_player_interacted() -> void:
	if dialogue_box == null and not dialogue_texts.is_empty():
		start_dialogue()
	elif dialogue_tween == null and dialogue_box != null:
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

	dialogue_box.finished_displaying_text.connect(_fade_dialogue_box)

func _fade_dialogue_box() -> void:
	dialogue_tween = create_tween()
	dialogue_tween.tween_property(dialogue_box, "modulate:a", 0.0, 1).set_delay(3)
	await dialogue_tween.finished
	dialogue_tween = null
	dialogue_box.queue_free()
	dialogue_box = null
	dialogue_finished.emit()

func get_head() -> Texture2D:
	return load(scene_file_path.get_base_dir().path_join("head.png"))
