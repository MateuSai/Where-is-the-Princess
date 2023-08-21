extends Button


func _ready() -> void:
	pressed.connect(func(): owner.start_game())
