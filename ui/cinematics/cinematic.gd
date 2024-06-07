class_name Cinematic extends Control

var slide: Control
var slide_number: int = 1

@export_dir var cinematic_dir: String
@export_file() var end_transition: String

func _init() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)

func _ready() -> void:
	_show_next_slide()

func _show_next_slide() -> void:
	assert(ResourceLoader.exists(cinematic_dir.path_join(str(slide_number)) + str(".tscn")))

	if slide:
		slide.queue_free()
		slide = null

	slide = load(cinematic_dir.path_join(str(slide_number) + str(".tscn"))).instantiate()
	add_child(slide)

	(slide.get_node("AnimationPlayer") as AnimationPlayer).play("animate")
	(slide.get_node("AnimationPlayer") as AnimationPlayer).animation_finished.connect(_on_slide_animation_finished, CONNECT_ONE_SHOT)

func _on_slide_animation_finished(_anim_name: String) -> void:
	slide_number += 1

	if ResourceLoader.exists(cinematic_dir.path_join(str(slide_number))):
		_show_next_slide()
	else:
		SceneTransistor.start_transition_to(end_transition)
