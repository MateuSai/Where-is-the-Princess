class_name DialogueBox extends MarginContainer

signal finished_displaying_text()
var last_label_size: Vector2
var expand_up: bool = false

@onready var label: RichTextLabel = $MarginContainer/RichTextLabel
@onready var add_letter_timer: Timer = $AddLetterTimer

func _ready() -> void:
	add_letter_timer.timeout.connect(_on_add_letter_timeout)
	last_label_size = label.size
	label.resized.connect(_on_label_resized)

func start_displaying_text(text_to_display: String) -> void:
	label.text = tr(text_to_display)
	start_displaying()

func start_displaying() -> void:
	label.visible_characters = 0
	add_letter_timer.start()

func show_all_text() -> void:
	label.visible_characters = label.text.length()
	_on_add_letter_timeout()

func _on_add_letter_timeout() -> void:
	label.visible_characters = clamp(label.visible_characters + 1, 0, label.text.length())
	if label.visible_characters == label.text.length():
		add_letter_timer.stop()
		finished_displaying_text.emit()

func _on_label_resized() -> void:
	if expand_up:
		position.y += last_label_size.y - label.size.y
		last_label_size = label.size
