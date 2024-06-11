extends Control

@export var _move_to: PackedScene

@export var _initial_delay: float = 1

var _splash_screens: Array[SplashScreen] = []

@onready var _splash_screen_container: CenterContainer = $SplashScreenContainer

func _ready() -> void:
	assert(_move_to)

	if OS.get_cmdline_user_args().has("--skip-splash-and-menu"):
		get_tree().call_deferred("change_scene_to_file", "res://Game.tscn")
		#SceneTransistor.start_transition_to("res://Game.tscn")
	elif OS.get_cmdline_user_args().has("--skip-splash"):
		get_tree().call_deferred("change_scene_to_file", "res://ui/menu.tscn")

	set_process_input(false)

	for splash_screen: SplashScreen in _splash_screen_container.get_children():
		splash_screen.hide()
		_splash_screens.push_back(splash_screen)

	await get_tree().create_timer(_initial_delay).timeout

	_start_splash_screen()

	set_process_input(true)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_skip"):
		_skip()

func _start_splash_screen() -> void:
	if _splash_screens.size() == 0:
		SceneTransistor.start_transition_to("res://ui/menu.tscn", true)
		#get_tree().change_scene_to_packed(_move_to)
		#SceneTransistor.scene_changed.emit(_move_to.resource_path)
	else:
		var splash_screen: SplashScreen = _splash_screens.pop_front()
		splash_screen.start()
		splash_screen.finished.connect(_start_splash_screen)

func _skip() -> void:
	_splash_screen_container.get_child(0).queue_free()
	_start_splash_screen()
