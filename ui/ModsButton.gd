extends Button


func _ready() -> void:
	pressed.connect(func(): owner.add_child(ModMenu.new()))
