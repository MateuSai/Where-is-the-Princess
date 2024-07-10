class_name SeedLineEdit extends LineEdit

var _previous_seed: String = ""

func _ready() -> void:
	text_changed.connect(func(new_text: String) -> void:
		if !text.is_valid_int() || text.to_int() < 0:
			text = _previous_seed
			caret_column = text.length()
			else:
				_previous_seed = text
	)
