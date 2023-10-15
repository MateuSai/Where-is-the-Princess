class_name ItemOnFloor extends Sprite2D

var item: Item
var can_pick_up: bool = false

@onready var interact_area: InteractArea = get_node("InteractArea")


func _ready() -> void:
	interact_area.body_entered.connect(func(player: Player):
		can_pick_up = can_pick_up_item(player)
		if can_pick_up:
			interact_area.sprite_material.set("shader_parameter/color", Color.WHITE)
			# interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
		else:
			interact_area.sprite_material.set("shader_parameter/color", Color.RED)
			interact_area.sprite_material.set("shader_parameter/interior_color", Color("#8f20178d"))
	)
	interact_area.body_exited.connect(func(_player: Player):
		if not can_pick_up:
			interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
	)


func enable_pick_up() -> void:
	interact_area.player_interacted.connect(func():
		if not can_pick_up:
			return
		_pick_item_and_free()
	)


# Llamar despues de _ready
@warning_ignore("shadowed_variable")
func initialize(item: Item) -> void:
	self.item = item
	if item is Rune:
		texture = item.RUNE_TEX
		var sprite: Sprite2D = Sprite2D.new()
		sprite.material = load("res://unshaded.tres")
		sprite.texture = item.get_icon()
		add_child(sprite)
	else:
		texture = item.get_icon()


func can_pick_up_item(player: Player) -> bool:
	return item.can_pick_up(player)


func _pick_item_and_free() -> void:
	item.pick_up(interact_area.player)
	queue_free()
