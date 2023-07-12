extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://Characters/Player/Player.tscn")

@export var debug: bool = true

var generation_thread: Thread = null

# @onready var ui: MainUi = get_node("UI")
@onready var rooms: Rooms = get_node("Rooms")
@onready var camera: Camera2D = get_node("Camera2D")
@onready var generating_dungeon_canvas_layer: CanvasLayer = get_node("GeneratingDungeonCanvasLayer")


func _init() -> void:
	var rand_seed: int = randi()
	print("Seed: " + str(rand_seed))
	seed(rand_seed)
	# seed(1439100935)


func _ready() -> void:
	if debug:
		camera.zoom = Vector2(0.2, 0.2)

	if debug:
		generating_dungeon_canvas_layer.hide()
		rooms.spawn_rooms()
	else:
		generating_dungeon_canvas_layer.show()
		rooms.spawn_rooms()
#		generation_thread = Thread.new()
#		generation_thread.start(rooms.spawn_rooms)
		rooms.generation_completed.connect(func():
			#generation_thread.wait_to_finish()
			generation_thread = null
			generating_dungeon_canvas_layer.hide()
		)

	await rooms.generation_completed

	camera.enabled = false
	var player: Player = PLAYER_SCENE.instantiate()
	player.position = rooms.start_room.get_node("PlayerSpawnPos").global_position
#	player.hp_changed.connect(ui._on_Player_hp_changed)
#	player.weapon_condition_changed.connect(ui._on_player_weapon_condition_changed)
#	player.weapon_droped.connect(ui._on_Player_weapon_droped)
#	player.weapon_picked_up.connect(ui._on_Player_weapon_picked_up)
#	player.weapon_switched.connect(ui._on_Player_weapon_switched)
	add_child(player)
	# ui.initialize(player)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		get_tree().paused = true


func _exit_tree() -> void:
	if generation_thread:
		generation_thread.wait_to_finish()
