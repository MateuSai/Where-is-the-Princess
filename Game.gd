class_name Game extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://Characters/Player/Player.tscn")

@export var debug: bool = true
@export var reload_on_generation_eror: bool = true
@export var execute_procedural_generation_on_thread: bool = true

var generation_thread: Thread = null

signal player_added()

var drag_enabled: bool = false
var mouse_pos_at_start_of_drag: Vector2
var scroll_horizontal_at_start_of_drag: float = 0
var scroll_vertical_at_start_of_drag: float = 0

# @onready var ui: MainUi = get_node("UI")
@onready var rooms: Rooms = get_node("Rooms")
@onready var camera: Camera2D = get_node("Camera2D")
@onready var generating_dungeon_canvas_layer: CanvasLayer = get_node("GeneratingDungeonCanvasLayer")
@onready var music: AudioStreamPlayer = $Music


func _ready() -> void:
	print_debug("Game _ready")

	set_process(false)

	if Globals.debug:
		set_process_input(true)
	else:
		set_process_input(false)

	rooms.generation_completed.connect(_on_rooms_generation_completed)

	if debug:
		camera.zoom = Vector2(0.2, 0.2)

		generating_dungeon_canvas_layer.hide()
		#rooms.spawn_rooms()
	else:
		generating_dungeon_canvas_layer.show()

	print_debug("Starting generation")
	if execute_procedural_generation_on_thread:
		rooms.generation_completed.connect(func() -> void:
			generation_thread.wait_to_finish()
			generation_thread = null
#			generating_dungeon_canvas_layer.hide()
		)
		generation_thread = Thread.new()
		generation_thread.start(rooms.spawn_rooms)
	else:
		rooms.spawn_rooms()
#		generating_dungeon_canvas_layer.hide()


func _on_rooms_generation_completed() -> void:
	print_debug("Generation completed")

	generating_dungeon_canvas_layer.hide()

	if not SavedData.get_biome_conf().music.is_empty():
		var stream: AudioStream = load(SavedData.get_biome_conf().music as String)
		assert(stream)
		music.stream = stream
		music.play()

	camera.enabled = false
	var player: Player = PLAYER_SCENE.instantiate()
	player.position = rooms.start_room.teleport_position.global_position

	add_child(player)
	player_added.emit()

	print_debug("_on_rooms_generation_completed finished executing")


func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_focus_next"):
#		get_tree().paused = true
	if event.is_action_pressed("ui_page_up") and SavedData.run_stats.level > 1:
		SavedData.run_stats.level -= 1
		get_tree().reload_current_scene()
	elif event.is_action_pressed("ui_page_down"):
		SavedData.run_stats.level += 1
		get_tree().reload_current_scene()

	if event.is_action_pressed("ui_drag_minimap"):
		mouse_pos_at_start_of_drag = get_local_mouse_position()
		scroll_horizontal_at_start_of_drag = camera.position.x
		scroll_vertical_at_start_of_drag = camera.position.y
		drag_enabled = true
		set_process(true)
	if event.is_action_released("ui_drag_minimap"):
		drag_enabled = false
		set_process(false)


func _process(_delta: float) -> void:
	if drag_enabled:
		@warning_ignore("narrowing_conversion")
		camera.position.x = scroll_horizontal_at_start_of_drag - get_local_mouse_position().x + mouse_pos_at_start_of_drag.x
		@warning_ignore("narrowing_conversion")
		camera.position.y = scroll_vertical_at_start_of_drag - get_local_mouse_position().y + mouse_pos_at_start_of_drag.y


func _exit_tree() -> void:
	if generation_thread:
		generation_thread.wait_to_finish()


func reload_generation(msg: String) -> void:
	#print_debug("Reloading scene...")
	if execute_procedural_generation_on_thread:
		generation_thread.wait_to_finish()
		generation_thread = null
	print_rich("[color=purple]%s. Reloading level generation...[/color]" % msg)
	get_tree().reload_current_scene()

	#print_debug("Scene reloaded")
