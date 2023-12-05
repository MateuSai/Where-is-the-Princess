extends HSlider

@onready var fps_label: Label = $"../FPSLabel"


func _ready() -> void:
	value = Engine.max_fps
	fps_label.text = str(value)
	value_changed.connect(func(new_value: int) -> void:
		Engine.max_fps = new_value
		fps_label.text = str(new_value)
	)
