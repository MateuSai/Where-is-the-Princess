class_name Cinematic extends Control

var slide: Control
var slide_number: int = 1
var times: Array[float]

@export_dir var cinematic_dir: String
@export_file() var end_transition: String = "res://Game.tscn"

@onready var music: AudioStreamPlayer = $Music

func _init() -> void:
	RenderingServer.set_default_clear_color(Color("6d1e0a"))

func _ready() -> void:
	_show_next_slide()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_skip") or event.is_action_pressed("ui_page_down"):
		_on_slide_animation_finished("skipped")
		music.seek(music.get_playback_position() + (slide.get_node("AnimationPlayer") as AnimationPlayer).current_animation_length - (slide.get_node("AnimationPlayer") as AnimationPlayer).current_animation_position)
	elif event.is_action_pressed("ui_page_up") and slide_number > 1:
		slide_number -= 2
		times.pop_back()
		times.pop_back()

		music.seek(times.reduce(func(accum: float, number: float) -> float: return accum + number, 0.0))

		_on_slide_animation_finished("skipped")

func _show_next_slide() -> void:
	assert(ResourceLoader.exists(cinematic_dir.path_join(str(slide_number)) + ".tscn"))

	if slide:
		slide.queue_free()
		slide = null

	slide = load(cinematic_dir.path_join(str(slide_number) + ".tscn")).instantiate()
	slide.clip_contents = true
	add_child(slide)

	(slide.get_node("AnimationPlayer") as AnimationPlayer).play("animate")
	(slide.get_node("AnimationPlayer") as AnimationPlayer).animation_finished.connect(_on_slide_animation_finished, CONNECT_ONE_SHOT)

	times.push_back((slide.get_node("AnimationPlayer") as AnimationPlayer).current_animation_length)

func _on_slide_animation_finished(_anim_name: String) -> void:
	slide_number += 1

	if ResourceLoader.exists(cinematic_dir.path_join(str(slide_number)) + ".tscn"):
		_show_next_slide()
	else:
		SceneTransistor.start_transition_to(end_transition)
