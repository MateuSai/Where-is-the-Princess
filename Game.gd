extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://Characters/Player/Player.tscn")

@export var debug: bool = true

# @onready var ui: MainUi = get_node("UI")
@onready var rooms: Rooms = get_node("Rooms")
@onready var camera: Camera2D = get_node("Camera2D")


func _init() -> void:
	var rand_seed: int = randi()
	print("Seed: " + str(rand_seed))
	seed(rand_seed)
	seed(858190307)


func _ready() -> void:
	if debug:
		camera.zoom = Vector2(0.25, 0.25)

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
