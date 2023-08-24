extends Button


func _ready() -> void:
	#pressed.connect(func(): owner.add_child(ModMenu.new()))
	pressed.connect(func(): get_tree().root.get_node("UserProfiles").popup_centered())
