class_name InteractArea extends Area2D


var item: PassiveItem

var player: Player = null

signal player_interacted()
signal player_entered()
signal player_exited()

var sprite_material: ShaderMaterial

enum Mode {
	OUTLINE,
	HIDE_SPRITE
}

@export var mode: Mode = Mode.OUTLINE
@export var path_to_sprite: NodePath
@onready var sprite: Node2D = get_node(path_to_sprite)


func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true) # To detect player
	set_collision_layer_value(7, true) # Interact Area

	if mode == Mode.OUTLINE:
		sprite_material = ShaderMaterial.new()
		sprite_material.shader = load("res://shaders_and_particles/outline.gdshader")
		sprite.material = sprite_material
	else:
		sprite.hide()

#	body_entered.connect(_on_player_entered)
#	body_exited.connect(_on_player_exited)

	_on_player_exited(null)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_interact"):
		get_viewport().set_input_as_handled()
		player_interacted.emit()
		body_entered.emit(player)  # To update the outline of the cursed idol, npcs, ...


@warning_ignore("shadowed_variable")
func _on_player_entered(player: Player) -> void:
	player_entered.emit()
	self.player = player
	set_process_unhandled_input(true)
	if mode == Mode.OUTLINE:
		sprite_material.set("shader_parameter/width", 1)
	else:
		sprite.show()


func _on_player_exited(_body: Node2D) -> void:
	player_exited.emit()
	set_process_unhandled_input(false)
	if mode == Mode.OUTLINE:
		sprite_material.set("shader_parameter/width", 0)
	else:
		sprite.hide()
