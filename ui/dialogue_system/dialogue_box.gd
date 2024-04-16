class_name DialogueBox extends MarginContainer

signal finished_displaying_text()

@onready var label: RichTextLabel = $MarginContainer/RichTextLabel
@onready var add_letter_timer: Timer = $AddLetterTimer

func _ready() -> void:
	add_letter_timer.timeout.connect(_on_add_letter_timeout)

func start_displaying_text(text_to_display: String) -> void:
	label.visible_characters = 0
	label.text = tr(text_to_display)
	add_letter_timer.start()

func show_all_text() -> void:
	label.visible_characters = label.text.length()
	_on_add_letter_timeout()

func _on_add_letter_timeout() -> void:
	label.visible_characters = clamp(label.visible_characters + 1, 0, label.text.length())
	if label.visible_characters == label.text.length():
		add_letter_timer.stop()
		finished_displaying_text.emit()
