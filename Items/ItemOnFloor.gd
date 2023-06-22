extends Area2D

var item: PassiveItem

var player: Player = null

@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var sprite_material: ShaderMaterial = sprite.material


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)

	_on_player_exited(null)

	initialize(EnhancedBoots.new())


# Llamar despues de _ready
@warning_ignore("shadowed_variable")
func initialize(item: PassiveItem) -> void:
	self.item = item
	sprite.texture = item.icon


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			player.pick_up_passive_item(item)
			free()


@warning_ignore("shadowed_variable")
func _on_player_entered(player: Player) -> void:
	self.player = player
	set_process_unhandled_input(true)
	sprite_material.set("shader_parameter/width", 1)


func _on_player_exited(_body: Node2D) -> void:
	set_process_unhandled_input(false)
	sprite_material.set("shader_parameter/width", 0)
