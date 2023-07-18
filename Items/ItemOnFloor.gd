class_name ItemOnFloor extends Sprite2D

var item: Item
var can_pick_up: bool = false

@onready var interact_area: InteractArea = get_node("InteractArea")


func _ready() -> void:
	interact_area.body_entered.connect(func(player: Player):
		can_pick_up = item.can_pick_up(player)
		if can_pick_up:
			interact_area.sprite_material.set("shader_parameter/color", Color.WHITE)
		else:
			interact_area.sprite_material.set("shader_parameter/color", Color.RED)
	)


func enable_pick_up() -> void:
	interact_area.player_interacted.connect(func():
		if not can_pick_up:
			return
		item.pick_up(interact_area.player)
		free()
	)


# Llamar despues de _ready
@warning_ignore("shadowed_variable")
func initialize(item: Item) -> void:
	self.item = item
	texture = item.icon
