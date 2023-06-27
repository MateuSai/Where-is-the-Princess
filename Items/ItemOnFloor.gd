class_name ItemOnFloor extends Sprite2D

var item: PassiveItem

@onready var interact_area: InteractArea = get_node("InteractArea")


func enable_pick_up() -> void:
	interact_area.player_interacted.connect(func():
		interact_area.player.pick_up_passive_item(item)
		free()
	)


# Llamar despues de _ready
@warning_ignore("shadowed_variable")
func initialize(item: PassiveItem) -> void:
	self.item = item
	texture = item.icon
