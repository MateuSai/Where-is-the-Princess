extends Button


func _ready() -> void:
	pressed.connect(func(): SceneTransistor.start_transition_to("res://Game.tscn"))
