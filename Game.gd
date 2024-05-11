class_name Game extends Node2D

const PLAYER_SCENE: PackedScene = preload ("res://Characters/Player/Player.tscn")

@export var debug: bool = true
@export var reload_on_generation_eror: bool = true
@export var execute_procedural_generation_on_thread: bool = true

static var wake_up: bool = false
static var came_from_next_level: bool = false

var generation_thread: Thread = null

signal player_added()

var drag_enabled: bool = false
var mouse_pos_at_start_of_drag: Vector2
var scroll_horizontal_at_start_of_drag: float = 0
var scroll_vertical_at_start_of_drag: float = 0

# @onready var ui: MainUi = get_node("UI")
@onready var rooms: Rooms = get_node("Rooms")
@onready var day_night_system: DayNightSystem = $DayNightSystem
@onready var camera: Camera2D = get_node("Camera2D")
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var generating_dungeon_canvas_layer: CanvasLayer = get_node("GeneratingDungeonCanvasLayer")
@onready var notification_container: NotificationContainer = %NotificationContainer
@onready var music: AudioStreamPlayer = $Music
@onready var minimap: MiniMap = get_node("UI/MenuTabContainer/MAP")

func _init() -> void:
	seed(SavedData.run_stats.get_level_seed())

func _ready() -> void:
	_init_biome(SavedData.get_biome_conf())

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

	#print_debug("Starting generation")
	if execute_procedural_generation_on_thread:
		rooms.generation_completed.connect(func() -> void:
			generation_thread.wait_to_finish()
			generation_thread=null
#			generating_dungeon_canvas_layer.hide()
		)
		generation_thread = Thread.new()
		generation_thread.start(rooms.spawn_rooms)
	else:
		rooms.spawn_rooms()
#		generating_dungeon_canvas_layer.hide()

func _init_biome(conf: BiomeConf) -> void:
	if conf.day_night_cycle:
		canvas_modulate.color = Color.BLACK

		if DayNightSystem.is_day():
			RenderingServer.set_default_clear_color(SavedData.get_biome_conf().background_color)
		else:
			RenderingServer.set_default_clear_color((SavedData.get_biome_conf().background_color as Color).darkened(0.5))
		day_night_system.day_started.connect(func() -> void:
			RenderingServer.set_default_clear_color(SavedData.get_biome_conf().background_color)
		)
		day_night_system.night_started.connect(func() -> void:
			RenderingServer.set_default_clear_color((SavedData.get_biome_conf().background_color as Color).darkened(0.5))
		)
	else:
		canvas_modulate.color = SavedData.get_biome_conf().light_color

		RenderingServer.set_default_clear_color(SavedData.get_biome_conf().background_color)

	player_added.connect(func() -> void:
		for weather_modificator: WeatherModificator in conf.weather_modificators:
			weather_modificator.enable(Globals.player)
	)

func _on_rooms_generation_completed() -> void:
	#print_debug("Generation completed")

	generating_dungeon_canvas_layer.hide()

	if not SavedData.get_biome_conf().music.is_empty():
		var stream: AudioStream = load(SavedData.get_biome_conf().music as String)
		assert(stream)
		music.stream = stream
		music.volume_db = SavedData.get_biome_conf().music_volume_db
		music.play()

	camera.enabled = false
	var player: Player = PLAYER_SCENE.instantiate()
	if wake_up:
		#wake_up = false
		var wake_up_marker: Marker2D = rooms.find_child("WakeUpMarker", true, false)
		assert(wake_up_marker.get_parent() is DungeonRoom)
		rooms.start_room = wake_up_marker.get_parent()
		player.position = wake_up_marker.global_position
	elif came_from_next_level:
		rooms.start_room = rooms.rooms[1]
		player.position = rooms.start_room.teleport_position.global_position
	else:
		player.position = rooms.start_room.teleport_position.global_position

	add_child(player)
	player_added.emit()

	#print_debug("_on_rooms_generation_completed finished executing")

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
	Log.info("[color=purple]%s. Reloading level generation...[/color]" % msg)

	rooms.generation_completed.disconnect(_on_rooms_generation_completed)

	for i: int in range(rooms.get_child_count() - 1, 0, -1): # We remove all rooms except the first one, that is the corridors
		rooms.get_child(i).free()
	($Rooms/CorridorTileMap as TileMap).clear()
	#minimap.clear()

	var signals: Array[Dictionary] = get_signal_list();
	for signal_dic: Dictionary in signals:
		var connection_list: Array[Dictionary] = get_signal_connection_list(signal_dic.name)
		for connection_dic: Dictionary in connection_list:
			connection_dic["signal"].disconnect(connection_dic.callable)

	minimap.set_script(null)
	minimap.set_script(MiniMap)

	# To reset all variables
	rooms.set_script(null)
	rooms.set_script(Rooms)

	minimap._ready()
	rooms._ready()
	_ready()
	#get_tree().reload_current_scene()

	#print_debug("Scene reloaded")

func show_notification(notification_scene: PackedScene, arguments: Dictionary) -> void:
	notification_container.add_notification_to_queue(notification_scene, arguments)
