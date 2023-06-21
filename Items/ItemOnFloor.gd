extends Area2D

@onready var sprite_material: ShaderMaterial = get_node("Sprite2D").material


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)

	_on_player_exited(null)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			print_debug("Implement this shit")


func _on_player_entered(_body: Node2D) -> void:
	set_process_unhandled_input(true)
	sprite_material.set("shader_parameter/width", 1)


func _on_player_exited(_body: Node2D) -> void:
	set_process_unhandled_input(false)
	sprite_material.set("shader_parameter/width", 0)
