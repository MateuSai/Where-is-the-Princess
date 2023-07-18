class_name InteractArea extends Area2D


var item: PassiveItem

var player: Player = null

signal player_interacted()

var sprite_material: ShaderMaterial

@export var path_to_sprite: NodePath
@onready var sprite: Node2D = get_node(path_to_sprite)


func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true) #Player

	sprite_material = ShaderMaterial.new()
	sprite_material.shader = load("res://Shaders and Particles/Outline.gdshader")
	sprite.material = sprite_material

	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)

	_on_player_exited(null)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_SPACE:
			player_interacted.emit()


@warning_ignore("shadowed_variable")
func _on_player_entered(player: Player) -> void:
	self.player = player
	set_process_unhandled_input(true)
	sprite_material.set("shader_parameter/width", 1)


func _on_player_exited(_body: Node2D) -> void:
	set_process_unhandled_input(false)
	sprite_material.set("shader_parameter/width", 0)
