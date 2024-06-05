extends CanvasLayer

signal scene_changed(new_scene_path: String)

var new_scene: String

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

func start_transition_to(path_to_scene: String, skip_fade_in: bool=false) -> void:
	new_scene = path_to_scene
	animation_player.play("change_scene_to_file")
	if skip_fade_in:
		animation_player.seek(0.45)

func change_scene_to_file() -> void:
	#print_debug("Changing scene...")
	var ok: int = get_tree().change_scene_to_file(new_scene) == OK
	assert(ok)
	scene_changed.emit(new_scene)
	#print_debug("Scene changed!")
