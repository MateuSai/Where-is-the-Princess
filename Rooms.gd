class_name Rooms extends Node2D

const SPAWN_ROOMS: Array[PackedScene] = [preload("res://Rooms/SpawnRoom0.tscn"), preload("res://Rooms/SpawnRoom1.tscn")]
const INTERMEDIATE_ROOMS: Array[PackedScene] = [preload("res://Rooms/Room0.tscn"), preload("res://Rooms/middle_room_1_0.tscn")]
const SPECIAL_ROOMS: Array[PackedScene] = [preload("res://Rooms/SpecialRoom0.tscn"), preload("res://Rooms/SpecialRoom1.tscn")]
const END_ROOMS: Array[PackedScene] = [preload("res://Rooms/EndRoom0.tscn")]
const SLIME_BOSS_SCENE: PackedScene = preload("res://Rooms/SlimeBossRoom.tscn")

const SPAWN_CIRCLE_RADIUS: float = 200

const TILE_SIZE: int = 16
const ATLAS_ID: int = 40
const FLOOR_TILE_COOR: Vector2i = Vector2i(3, 1)
const FULL_WALL_COORDS: Array[Vector2i] = [Vector2i(6, 4), Vector2i(7, 4), Vector2i(8, 4), Vector2i(6, 5), Vector2i(7, 5), Vector2i(8, 5)]
const UPPER_WALL_COOR: Vector2i = Vector2i(2, 7)
const BOTTOM_WALL_COOR: Vector2i = Vector2i(2, 6)
const LEFT_BOTTOM_WALL_COOR: Vector2i = Vector2i(1, 6)
const RIGHT_BOTTOM_WALL_COOR: Vector2i = Vector2i(5, 6)
const LEFT_WALL_COOR: Vector2i = Vector2i(4, 5)
const LAST_LEFT_WALL_COOR: Vector2i = Vector2i(4, 6)
const RIGHT_WALL_COOR: Vector2i = Vector2i(3, 5)
const LAST_RIGHT_WALL_COOR: Vector2i = Vector2i(3, 6)
const UPPER_WALL_LEFT_COOR: Vector2i = Vector2i(1, 7)
const UPPER_WALL_RIGHT_COOR: Vector2i = Vector2i(5, 7)
const UPPER_WALL_RIGHT_CORNER_COOR: Vector2i = Vector2i(3, 4)
const UPPER_WALL_LEFT_CORNER_COOR: Vector2i = Vector2i(4, 4)

signal generation_completed()

var rooms: Array[DungeonRoom] = []
var start_room: DungeonRoom
var end_room: DungeonRoom
var mst_astar: AStar2D = null
# DEBUG
@onready var debug: bool = get_parent().debug
@export var debug_check_entry_positions: bool = false
@export var pause_between_steps: float = 1.2
@export var add_tile_group_time: float = 0.02
var room_centers: Array[Vector2] = []
var delaunay_indices: PackedInt32Array
# Tengo que declarar esto aquí porque esta wea culiada no me deja dibujar fuera de _draw
var vertical_corridor_rect: Rect2
var horizontal_corridor_rect: Rect2
var room_rect: Rect2

@export var num_levels: int = 5

# @onready var player: CharacterBody2D = get_parent().get_node("Player")

@onready var corridor_tile_map: TileMap = get_node("CorridorTileMap")


func _ready() -> void:
	set_physics_process(false)

	if debug:
		corridor_tile_map.z_index = 1
		var corridor_material: CanvasItemMaterial = CanvasItemMaterial.new()
		corridor_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		corridor_tile_map.material = corridor_material
	else:
		corridor_tile_map.z_index = 0
		corridor_tile_map.material = null

	SavedData.num_floor += 1
	if SavedData.num_floor == 3:
		num_levels = 3


func _physics_process(delta: float) -> void:
	var no_more_rooms_moving: bool = true

	#var dirs: Array[Vector2] = []
	for room in rooms:
		var dir: Vector2 = room.get_separation_steering_dir(rooms, delta)
		#dirs.push_back(dir)
		if dir != Vector2.ZERO:
			no_more_rooms_moving = false
#	for i in rooms.size():
#		var room: DungeonRoom = rooms[i]
#		room.float_position += dirs[i] * 0.01 * delta
#		room.position = round(room.float_position/TILE_SIZE) * TILE_SIZE

#	for i in dirs.size():
#		if dirs[i] != Vector2.ZERO:
#			print(str(i) + ": " + str(dirs[i]))

	if no_more_rooms_moving:
		set_physics_process(false)
		_create_corridors()


func spawn_rooms() -> void:
	start_room = SPAWN_ROOMS[randi() % SPAWN_ROOMS.size()].instantiate()
	rooms.push_back(start_room)
	end_room = END_ROOMS[randi() % END_ROOMS.size()].instantiate()
	rooms.push_back(end_room)
	var inter_rooms: Array[PackedScene] = INTERMEDIATE_ROOMS.duplicate(true)
	inter_rooms.append_array(SavedData.custom_rooms)
	for i in 10:
		#rooms.push_back(INTERMEDIATE_ROOMS[0].instantiate())
		rooms.push_back(inter_rooms[randi() % inter_rooms.size()].instantiate())

	for room in rooms:
		add_child(room)
	var start_room_pos: Vector2 = start_room.get_random_circle_spawn_point(SPAWN_CIRCLE_RADIUS)
	rooms[0].float_position = start_room_pos # rooms[0] es la habitación de spawn
	rooms[1].float_position = start_room_pos * -1 # rooms[1] es la habitación de salida
	for room in rooms:
		# Ya que ya hemos posicionado start y end antes
		if not room in [start_room, end_room]:
			room.float_position = room.get_random_circle_spawn_point(SPAWN_CIRCLE_RADIUS)
		# add_child(room)
		if debug:
			room.get_node("DebugRoomId").text = str(rooms.find(room))

	# return
	set_physics_process(true)


func _create_corridors() -> void:
	#var room_centers: Array[Vector2] = []
	for room in rooms:
		room_centers.push_back(room.position + room.vector_to_center)

	delaunay_indices = Geometry2D.triangulate_delaunay(room_centers)
	#print(delaunay_indices)
	#print(room_centers)
	if debug:
		queue_redraw()
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	var delaunay_astar: AStar2D = AStar2D.new()
	for i in room_centers.size():
		delaunay_astar.add_point(i, room_centers[i])
	for i in delaunay_indices.size() / 3.0:
		i = i * 3
		delaunay_astar.connect_points(delaunay_indices[i], delaunay_indices[i+1])
		delaunay_astar.connect_points(delaunay_indices[i+1], delaunay_indices[i+2])
		delaunay_astar.connect_points(delaunay_indices[i+2], delaunay_indices[i])

	mst_astar = AStar2D.new()
	mst_astar.add_point(mst_astar.get_available_point_id(), room_centers[0])
	delaunay_astar.set_point_disabled(0)

	for i in range(1, delaunay_astar.get_point_count()):
		var min_dist = INF  # Minimum distance found so far
		var min_p = null  # Position of that node
		var p = null  # Current position
		# Loop through the points in the path
		for id in mst_astar.get_point_ids():
			var point: Vector2 = mst_astar.get_point_position(id)
			# Loop through the remaining nodes in the given array
			#print(delaunay_astar.get_point_count())
			for j in delaunay_astar.get_point_count():
				if delaunay_astar.is_point_disabled(j):
					continue
				var point2: Vector2 = delaunay_astar.get_point_position(j)
			# If the node is closer, make it the closest
				if delaunay_astar.get_point_connections(room_centers.find(point)).has(j) and point.distance_to(point2) < min_dist:
					min_dist = point.distance_to(point2)
					min_p = point2
					p = point
		# Insert the resulting node into the path and add
		# its connection
		var n: int = room_centers.find(min_p)
		mst_astar.add_point(n, min_p)
		mst_astar.connect_points(mst_astar.get_closest_point(p), n)
		# Remove the node from the array so it isn't visited again
		delaunay_astar.set_point_disabled(room_centers.find(min_p))
		#rooms_not_used.remove_at(rooms_not_used.find(min_p))

	if debug:
		queue_redraw()
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	# Añadimos alguna conexion extra
	for id in delaunay_astar.get_point_count():
		delaunay_astar.set_point_disabled(id, false)
	var points_that_could_be_connected: Array[Array] = []
	for id in delaunay_astar.get_point_count():
		for id2 in range(id + 1, delaunay_astar.get_point_count()):
			# print(str(id) + ": " + str(delaunay_astar.get_point_connections(id)))
			if delaunay_astar.get_point_connections(id).has(id2) and not mst_astar.get_point_connections(id).has(id2) and not points_that_could_be_connected.has([id, id2]) and not points_that_could_be_connected.has([id2, id]):
				points_that_could_be_connected.push_back([id, id2])
	if debug:
		print("Connections not used after mst: " + str(points_that_could_be_connected))

	var number_of_extra_connections: int = round(points_that_could_be_connected.size() * 0.2)
	for i in number_of_extra_connections:
		var rand: int = randi() % points_that_could_be_connected.size()
		mst_astar.connect_points(points_that_could_be_connected[rand][0], points_that_could_be_connected[rand][1])
		points_that_could_be_connected.remove_at(rand)

	if debug:
		queue_redraw()
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	await _add_floor_tiles()

	# await add_tiles.call()
	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	# CORRIDOR WALLS
	corridor_tile_map.set_cells_terrain_connect(0, corridor_tile_map.get_used_cells(0), 0, 0)

	var entry_cells: Array[Vector2i] = []
	for room in rooms:
		for used_entry in room.used_entries:
			for pos_node in used_entry.get_children():
				var cell: Vector2i = corridor_tile_map.local_to_map(pos_node.global_position)
				corridor_tile_map.erase_cell(0, cell)
				entry_cells.push_back(cell)

	for cell_pos in corridor_tile_map.get_used_cells(0):
		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos) in FULL_WALL_COORDS:
			if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.UP) == RIGHT_WALL_COOR:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_LEFT_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.UP) == LEFT_WALL_COOR:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_RIGHT_COOR)
			else:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_COOR)

			if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.RIGHT) == Vector2i(-1, -1) and not entry_cells.has(cell_pos + Vector2i.RIGHT + Vector2i.DOWN):
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.RIGHT, ATLAS_ID, RIGHT_WALL_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.RIGHT + Vector2i.UP, ATLAS_ID, UPPER_WALL_RIGHT_CORNER_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT) == Vector2i(-1, -1) and not entry_cells.has(cell_pos + Vector2i.LEFT + Vector2i.DOWN):
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.LEFT, ATLAS_ID, LEFT_WALL_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.LEFT + Vector2i.UP, ATLAS_ID, UPPER_WALL_LEFT_CORNER_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos) == FLOOR_TILE_COOR and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) != FLOOR_TILE_COOR:
			if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) == RIGHT_WALL_COOR:
				corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, LEFT_BOTTOM_WALL_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) == LEFT_WALL_COOR:
				corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, RIGHT_BOTTOM_WALL_COOR)
			else:
				corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, BOTTOM_WALL_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos) == LEFT_WALL_COOR and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) == Vector2i(-1, -1) and not entry_cells.has(cell_pos + Vector2i.ONE):
			corridor_tile_map.set_cell(0, cell_pos, ATLAS_ID, LAST_LEFT_WALL_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos) == RIGHT_WALL_COOR and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) == Vector2i(-1, -1)and not entry_cells.has(cell_pos + Vector2i.DOWN + Vector2i.LEFT):
			corridor_tile_map.set_cell(0, cell_pos, ATLAS_ID, LAST_RIGHT_WALL_COOR)

		if debug:
				await get_tree().create_timer(add_tile_group_time).timeout

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	for room in rooms:
		room.add_doors_and_walls(corridor_tile_map)

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps * 2).timeout

	emit_signal("generation_completed")


func _add_floor_tiles() -> void:
	for id in mst_astar.get_point_count():
		for connection_with in mst_astar.get_point_connections(id):
			var dif: Vector2 = room_centers[connection_with] - room_centers[id]
			if debug:
				print("Connecting " + str(id) + " with " + str(connection_with) + "...")
				print("\tdif is " + str(dif) + " pixels")
			if abs(dif.x) < TILE_SIZE * 8:
				if debug:
					print("\tCreating vertical corridor...")
				if rooms[id if dif.y > 0 else connection_with].has_entry(DungeonRoom.EntryDirection.DOWN) and rooms[connection_with if dif.y > 0 else id].has_entry(DungeonRoom.EntryDirection.UP):
					var above: Node = rooms[id if dif.y > 0 else connection_with].get_random_entry(DungeonRoom.EntryDirection.DOWN)
					var below: Node = rooms[connection_with if dif.y > 0 else id].get_random_entry(DungeonRoom.EntryDirection.UP)
					await _create_vertical_corridor(above, below)
				else:
					printerr("\tImplement something here")
			elif abs(dif.y) < TILE_SIZE * 8:
				if debug:
					print("\tCreating horizontal corridor...")
				if rooms[id if dif.x > 0 else connection_with].has_entry(DungeonRoom.EntryDirection.RIGHT) and rooms[connection_with if dif.x > 0 else id].has_entry(DungeonRoom.EntryDirection.LEFT):
					var left: Node = rooms[id if dif.x > 0 else connection_with].get_random_entry(DungeonRoom.EntryDirection.RIGHT)
					var right: Node = rooms[connection_with if dif.x > 0 else id].get_random_entry(DungeonRoom.EntryDirection.LEFT)
					await _create_horizontal_corridor(left, right)
				else:
					printerr("\tImplement something here")
			else:
				if debug:
					print("\tCreating l corridor...")
				if dif.x > 0 and dif.y > 0:
					var directions: Array[Array] = [[DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.UP], [DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.LEFT]]
					await _analyze_and_create_l_corridor(id, connection_with, directions)
				elif dif.x > 0 and dif.y < 0:
					var directions: Array[Array] = [[DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.DOWN], [DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.LEFT]]
					await _analyze_and_create_l_corridor(id, connection_with, directions)
				elif dif.x < 0 and dif.y > 0:
					var directions: Array[Array] = [[DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.UP], [DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.RIGHT]]
					await _analyze_and_create_l_corridor(id, connection_with, directions)
				else: # dif.x < 0 and dif.y < 0
					var directions: Array[Array] = [[DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.DOWN], [DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.RIGHT]]
					await _analyze_and_create_l_corridor(id, connection_with, directions)

			mst_astar.disconnect_points(id, connection_with)


func _analyze_and_create_l_corridor(id: int, connection_with: int, directions: Array[Array]) -> void:
	var rand: int = randi() % 2
	if rooms[id].has_entry(directions[rand][0]) and rooms[connection_with].has_entry(directions[rand][1]) and await _check_entry_positions(id, connection_with, directions[rand][0], directions[rand][1]):
		await _create_l_corridor(rooms[id].get_random_entry(directions[rand][0]), rooms[connection_with].get_random_entry(directions[rand][1]), directions[rand][0], directions[rand][1])
	else:
		rand = (int(rand == 0))
		if rooms[id].has_entry(directions[rand][0]) and rooms[connection_with].has_entry(directions[rand][1]) and await _check_entry_positions(id, connection_with, directions[rand][0], directions[rand][1]):
			await _create_l_corridor(rooms[id].get_random_entry(directions[rand][0]), rooms[connection_with].get_random_entry(directions[rand][1]), directions[rand][0], directions[rand][1])
		else:
			printerr("\tI tried both possible directions, but it's impossible to create l corridor")


func _check_entry_positions(id: int, connection_with: int, id_dir: DungeonRoom.EntryDirection, connection_with_dir: DungeonRoom.EntryDirection) -> bool:
	var id_entry_position: Vector2 = rooms[id].get_entry_position(id_dir)
	var connection_with_entry_position: Vector2 = rooms[connection_with].get_entry_position(connection_with_dir)

#	var vertical_corridor_rect: Rect2
#	var horizontal_corridor_rect: Rect2
	if id_dir == DungeonRoom.EntryDirection.UP or id_dir == DungeonRoom.EntryDirection.DOWN:
		vertical_corridor_rect = Rect2(id_entry_position.x - 32, id_entry_position.y, TILE_SIZE * 4, connection_with_entry_position.y - id_entry_position.y)
		horizontal_corridor_rect = Rect2(connection_with_entry_position.x, connection_with_entry_position.y - 32, id_entry_position.x - connection_with_entry_position.x, TILE_SIZE * 4)
	else:
		vertical_corridor_rect = Rect2(connection_with_entry_position.x - 32, connection_with_entry_position.y, TILE_SIZE * 4, id_entry_position.y - connection_with_entry_position.y)
		horizontal_corridor_rect = Rect2(id_entry_position.x, id_entry_position.y - 32, connection_with_entry_position.x - id_entry_position.x, TILE_SIZE * 4)

	for room in rooms:
		if room == rooms[id] or room == rooms[connection_with]:
			continue # Para que no detecta las habitaciones que se conectan, solo las otras

		room_rect = Rect2(Vector2i(room.position) + (room.tilemap.get_used_rect().position * 16), (room.tilemap.get_used_rect().size * 16))
		# print("Room " + str(rooms.find(room)) + "  " + str(room_rect))

		if debug_check_entry_positions:
			queue_redraw()
			await get_tree().create_timer(0.6).timeout
		if room_rect.intersects(vertical_corridor_rect.abs()) or room_rect.intersects(horizontal_corridor_rect.abs()):
			return false

	if id_dir == DungeonRoom.EntryDirection.RIGHT or connection_with_dir == DungeonRoom.EntryDirection.LEFT:
		if not id_entry_position.x < (connection_with_entry_position.x - TILE_SIZE * 2):
			return false
	else:
		if not connection_with_entry_position.x < (id_entry_position.x - TILE_SIZE * 2):
			return false
	if id_dir == DungeonRoom.EntryDirection.DOWN or connection_with_dir == DungeonRoom.EntryDirection.UP:
		if not id_entry_position.y < (connection_with_entry_position.y - TILE_SIZE * 2):
			return false
	else:
		if not connection_with_entry_position.y < (id_entry_position.y - TILE_SIZE * 2):
			return false

	return true


# above and below are entries, with 2 children
func _create_vertical_corridor(above: Node, below: Node) -> void:
	assert(above.get_child_count() == 2 and below.get_child_count() == 2)

	const MIN_TILES_TO_MAKE_DESVIATION: int = 2

	var above_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(above.get_child(0).global_position), corridor_tile_map.local_to_map(above.get_child(1).global_position)]
	var below_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(below.get_child(0).global_position), corridor_tile_map.local_to_map(below.get_child(1).global_position)]

	# var y_start: int = above_tiles[0].y
	var dis: int = below_tiles[0].y - above_tiles[0].y
	var center: int = floor((dis) / 2.0)

	for i in range(1, center):
		#corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * i + Vector2i.LEFT, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * i, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN * i, 40, FLOOR_TILE_COOR)
		#corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN * i + Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	for i in range(1, dis - center - MIN_TILES_TO_MAKE_DESVIATION + 1):
		#corridor_tile_map.set_cell(0, below_tiles[0] + Vector2i.UP * i + Vector2i.LEFT, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, below_tiles[0] + Vector2i.UP * i, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, below_tiles[1] + Vector2i.UP * i, 40, FLOOR_TILE_COOR)
		#corridor_tile_map.set_cell(0, below_tiles[1] + Vector2i.UP * i + Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	if above_tiles[0].x > below_tiles[0].x:
		for i in above_tiles[1].x - below_tiles[0].x + 1:
			corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN * center + (i) * Vector2i.LEFT, 40, FLOOR_TILE_COOR)
			corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN + Vector2i.DOWN * center + (i) * Vector2i.LEFT, 40, FLOOR_TILE_COOR)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	elif above_tiles[0].x < below_tiles[0].x:
		for i in below_tiles[0].x - above_tiles[1].x + 3:
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	else:
		for i in MIN_TILES_TO_MAKE_DESVIATION:
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout


func _create_horizontal_corridor(left: Node, right: Node) -> void:
	assert(left.get_child_count() == 2 and right.get_child_count() == 2)

	const MIN_TILES_TO_MAKE_DESVIATION: int = 2

	var left_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(left.get_child(0).global_position), corridor_tile_map.local_to_map(left.get_child(1).global_position)]
	var right_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(right.get_child(0).global_position), corridor_tile_map.local_to_map(right.get_child(1).global_position)]

	# var x_start: int = left_tiles[0].x
	var dis: int = right_tiles[0].x - left_tiles[0].x
	var center: int = floor((dis) / 2.0)

	for i in range(1, center):
		corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT * i, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, left_tiles[1] + Vector2i.RIGHT * i, 40, FLOOR_TILE_COOR)
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	for i in range(1, dis - center - MIN_TILES_TO_MAKE_DESVIATION + 1):
		corridor_tile_map.set_cell(0, right_tiles[0] + Vector2i.LEFT * i, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, right_tiles[1] + Vector2i.LEFT * i, 40, FLOOR_TILE_COOR)
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	if left_tiles[0].y > right_tiles[0].y:
		for i in left_tiles[1].y - right_tiles[0].y + 1:
			corridor_tile_map.set_cell(0, left_tiles[1] + Vector2i.RIGHT * center + (i) * Vector2i.UP, 40, FLOOR_TILE_COOR)
			corridor_tile_map.set_cell(0, left_tiles[1] + Vector2i.RIGHT + Vector2i.RIGHT * center + (i) * Vector2i.UP, 40, FLOOR_TILE_COOR)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	elif left_tiles[0].y < right_tiles[0].y:
		for i in right_tiles[0].y - left_tiles[1].y + 3:
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, 40, FLOOR_TILE_COOR)
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, 40, FLOOR_TILE_COOR)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	else:
		for i in MIN_TILES_TO_MAKE_DESVIATION:
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, 40, FLOOR_TILE_COOR)
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, 40, FLOOR_TILE_COOR)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout


func _create_l_corridor(from: Node, to: Node, from_dir: DungeonRoom.EntryDirection, to_dir: DungeonRoom.EntryDirection) -> void:
	assert(from.get_child_count() == 2 and to.get_child_count() == 2)

	var vertical_entry: Node
	var horizontal_entry: Node
	var vertical_dir: DungeonRoom.EntryDirection
	var horizontal_dir: DungeonRoom.EntryDirection
	if from_dir == DungeonRoom.EntryDirection.UP or from_dir == DungeonRoom.EntryDirection.DOWN:
		vertical_entry = from
		horizontal_entry = to
		vertical_dir = from_dir
		horizontal_dir = to_dir
	else:
		vertical_entry = to
		horizontal_entry = from
		vertical_dir = to_dir
		horizontal_dir = from_dir

	var vertical_entry_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(vertical_entry.get_child(0).global_position), corridor_tile_map.local_to_map(vertical_entry.get_child(1).global_position)]
	var horizontal_entry_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(horizontal_entry.get_child(0).global_position), corridor_tile_map.local_to_map(horizontal_entry.get_child(1).global_position)]
	# print("fdsfsd" + str(from_tiles[0]) + " " + str(to_tiles[0]))

	if vertical_dir == DungeonRoom.EntryDirection.UP or vertical_dir == DungeonRoom.EntryDirection.DOWN:
		var y_coord: int = vertical_entry_tiles[0].y
		while y_coord != (horizontal_entry_tiles[0].y if vertical_dir == DungeonRoom.EntryDirection.UP else horizontal_entry_tiles[1].y):
			y_coord += (-1 if vertical_dir == DungeonRoom.EntryDirection.UP else 1)
			corridor_tile_map.set_cell(0, Vector2i(vertical_entry_tiles[0].x, y_coord), 40, FLOOR_TILE_COOR)
			corridor_tile_map.set_cell(0, Vector2i(vertical_entry_tiles[1].x, y_coord), 40, FLOOR_TILE_COOR)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout

		var x_coord: int = horizontal_entry_tiles[0].x + (-1 if horizontal_dir == DungeonRoom.EntryDirection.LEFT else 1)
		while x_coord != (vertical_entry_tiles[1].x):
			corridor_tile_map.set_cell(0, Vector2i(x_coord, horizontal_entry_tiles[0].y), 40, FLOOR_TILE_COOR)
			corridor_tile_map.set_cell(0, Vector2i(x_coord, horizontal_entry_tiles[1].y), 40, FLOOR_TILE_COOR)
			x_coord += (-1 if horizontal_dir == DungeonRoom.EntryDirection.LEFT else 1)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout


func _draw() -> void:
	if mst_astar == null:
		for i in delaunay_indices.size() / 3.0:
			draw_line(room_centers[delaunay_indices[i*3]], room_centers[delaunay_indices[i*3+1]], Color.GREEN, 7)
			draw_line(room_centers[delaunay_indices[i*3+1]], room_centers[delaunay_indices[i*3+2]], Color.GREEN, 7)
			draw_line(room_centers[delaunay_indices[i*3+2]], room_centers[delaunay_indices[i*3]], Color.GREEN, 7)
	else:
		for i in mst_astar.get_point_count():
			for j in mst_astar.get_point_connections(i):
				draw_line(room_centers[room_centers.find(mst_astar.get_point_position(i))], room_centers[room_centers.find(mst_astar.get_point_position(j))], Color.YELLOW, 7)

	draw_rect(vertical_corridor_rect, Color.DEEP_SKY_BLUE, true)
	draw_rect(horizontal_corridor_rect, Color.DEEP_SKY_BLUE, true)
	draw_rect(room_rect, Color.WEB_MAROON, true)


#func _get_random_point_in_circle(radius: float) -> Vector2:
#	var t: float = 2 * PI * randf()
#	var u: float = randf() + randf()
#	var r = null
#	if u > 1:
#		r = 2 - u
#	else:
#		r = u
#
#	return Vector2(radius * r * cos(t), radius * r * sin(t))
