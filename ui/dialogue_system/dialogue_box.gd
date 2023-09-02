class_name DialogueBox extends MarginContainer

signal finished_displaying_text()

@onready var label: RichTextLabel = $MarginContainer/RichTextLabel
@onready var add_letter_timer: Timer = $AddLetterTimer


func _ready() -> void:
	add_letter_timer.timeout.connect(func():
		label.visible_characters = clamp(label.visible_characters + 1, 0, label.text.length())
		if label.visible_characters == label.text.length():
			add_letter_timer.stop()
			finished_displaying_text.emit()
	)



func start_displaying_text(text_to_display: String) -> void:
	label.visible_characters = 0
	label.text = text_to_display
	add_letter_timer.start()
