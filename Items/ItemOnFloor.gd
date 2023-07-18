class_name ItemOnFloor extends Sprite2D

var item: Item

@onready var interact_area: InteractArea = get_node("InteractArea")


func enable_pick_up() -> void:
	interact_area.player_interacted.connect(func():
		item.pick_up(interact_area.player)
		free()
	)


# Llamar despues de _ready
@warning_ignore("shadowed_variable")
func initialize(item: Item) -> void:
	self.item = item
	texture = item.icon
