class_name Mole extends Enemy


const HOLE_TILE_COOR: Vector2i = Vector2i(1, 3)

var holes: Array[Vector2] = []


func _ready() -> void:
	super()
	var tilemap: TileMap = room.get_node("TileMap")

	for tile_pos in tilemap.get_used_cells_by_id(0, 0, HOLE_TILE_COOR):
		holes.push_back(room.position + tilemap.map_to_local(tile_pos))

	state_machine.set_state(state_machine.states.below)
	#come_out()


func come_out() -> void:
	var holes_array: Array[Vector2] = holes.duplicate(true)
	var rand_hole: Vector2 = holes_array[randi() % holes_array.size()]
	holes_array.erase(rand_hole)
	var rand_hole2: Vector2 = holes_array[randi() % holes_array.size()]

	# print("rand_hole: " + str(rand_hole) + "  rand_hole2: " + str(rand_hole2))

	global_position = rand_hole
	navigation_agent.target_position = rand_hole2


func _on_PathTimer_timeout() -> void:
	pass
