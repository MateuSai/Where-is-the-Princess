class_name Mole extends Enemy

const ROCK_SCENE: PackedScene = preload("res://Weapons/Projectiles/Rock.tscn")

const HOLE_TILE_COOR: Vector2i = Vector2i(1, 4)
#const FLOOR_TILES_ATLAS_COOR: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2), Vector2i(8, 2), Vector2i(0, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3), Vector2i(7, 3), Vector2i(8, 3)]

var holes: Array[Vector2] = []
#var floor_pos: Array[Vector2] = []

@onready var attack_timer: Timer = get_node("AttackTimer")


func _ready() -> void:
	super()
	var tilemap: TileMap = room.get_node("TileMap")

	for cell in tilemap.get_used_cells(0):
		if tilemap.get_cell_atlas_coords(0, cell) == HOLE_TILE_COOR:
			holes.push_back(room.position + tilemap.map_to_local(cell))

	attack_timer.timeout.connect(func():
		var rock: Projectile = ROCK_SCENE.instantiate()
		rock.exclude = [self]
		room.add_child(rock)
		rock.launch(position, (player.position - global_position).normalized(), 130)
		attack_timer.start(randf_range(0.7, 1.5))
	)

	state_machine.set_state(state_machine.states.below)
	#come_out()


func come_out() -> void:
	show()

	var holes_array: Array[Vector2] = holes.duplicate(true)
	var rand_hole: Vector2 = holes_array[randi() % holes_array.size()]
	holes_array.erase(rand_hole)
	var rand_hole2: Vector2 = holes_array[randi() % holes_array.size()]

	# print("rand_hole: " + str(rand_hole) + "  rand_hole2: " + str(rand_hole2))

	global_position = holes[randi() % holes.size()]
	navigation_agent.target_position = rand_hole2


func _on_PathTimer_timeout() -> void:
	pass
