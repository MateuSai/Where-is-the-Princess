class_name Rooms extends Node2D

const SPAWN_ROOMS: Array = [preload("res://Rooms/SpawnRoom0.tscn"), preload("res://Rooms/SpawnRoom1.tscn")]
const INTERMEDIATE_ROOMS: Array = [preload("res://Rooms/Room0.tscn"), preload("res://Rooms/Room1.tscn"), preload("res://Rooms/Room2.tscn"), preload("res://Rooms/Room3.tscn"), preload("res://Rooms/Room4.tscn")]
const SPECIAL_ROOMS: Array = [preload("res://Rooms/SpecialRoom0.tscn"), preload("res://Rooms/SpecialRoom1.tscn")]
const END_ROOMS: Array = [preload("res://Rooms/EndRoom0.tscn")]
const SLIME_BOSS_SCENE: PackedScene = preload("res://Rooms/SlimeBossRoom.tscn")

const TILE_SIZE: int = 16
const FLOOR_TILE_INDEX: int = 14
const RIGHT_WALL_TILE_INDEX: int = 5
const LEFT_WALL_TILE_INDEX: int = 6

var rooms: Array[DungeonRoom] = []
var start_room: DungeonRoom
var end_room: DungeonRoom
var mst_astar: AStar2D = null
# DEBUG
@export var debug: bool = true
var room_centers: Array[Vector2] = []
var delaunay_indices: PackedInt32Array

@export var num_levels: int = 5

@onready var player: CharacterBody2D = get_parent().get_node("Player")


func _ready() -> void:
	set_physics_process(false)

	SavedData.num_floor += 1
	if SavedData.num_floor == 3:
		num_levels = 3
	_spawn_rooms()


func _physics_process(delta: float) -> void:
	var no_more_rooms_moving: bool = true

	for room in rooms:
		if not room.separation_steering(rooms, delta):
			no_more_rooms_moving = false

	if no_more_rooms_moving:
		set_physics_process(false)
		_create_corridors()


func _spawn_rooms() -> void:
	start_room = SPAWN_ROOMS[randi() % SPAWN_ROOMS.size()].instantiate()
	rooms.push_back(start_room)
	end_room = END_ROOMS[randi() % END_ROOMS.size()].instantiate()
	rooms.push_back(end_room)
	for i in 10:
		rooms.push_back(INTERMEDIATE_ROOMS[randi() % INTERMEDIATE_ROOMS.size()].instantiate())

	for room in rooms:
		room.float_position = _get_random_point_in_circle(200)
		add_child(room)

	set_physics_process(true)

#	var previous_room: Node2D
#	var special_room_spawned: bool = false
#
#	for i in num_levels:
#		var room: Node2D
#
#		if i == 0:
#			room = SPAWN_ROOMS[randi() % SPAWN_ROOMS.size()].instantiate()
#			player.position = room.get_node("PlayerSpawnPos").position
#		else:
#			if i == num_levels - 1:
#				room = END_ROOMS[randi() % END_ROOMS.size()].instantiate()
#			else:
#				if SavedData.num_floor == 3:
#					room = SLIME_BOSS_SCENE.instantiate()
#				else:
#					if (randi() % 3 == 0 and not special_room_spawned) or (i == num_levels - 2 and not special_room_spawned):
#						room = SPECIAL_ROOMS[randi() % SPECIAL_ROOMS.size()].instantiate()
#						special_room_spawned = true
#					else:
#						room = INTERMEDIATE_ROOMS[randi() % INTERMEDIATE_ROOMS.size()].instantiate()
#
#			var previous_room_tilemap: TileMap = previous_room.get_node("TileMap")
#			var previous_room_door: StaticBody2D = previous_room.get_node("Doors/Door")
#			var exit_tile_pos: Vector2i = previous_room_tilemap.local_to_map(previous_room_door.position) + Vector2i.UP * 2
#
#			var corridor_height: int = randi() % 5 + 2
#			for y in corridor_height:
#				previous_room_tilemap.set_cell(0, exit_tile_pos + Vector2i(-2, -y), LEFT_WALL_TILE_INDEX, Vector2i.ZERO)
#				previous_room_tilemap.set_cell(0, exit_tile_pos + Vector2i(-1, -y), FLOOR_TILE_INDEX, Vector2i.ZERO)
#				previous_room_tilemap.set_cell(0, exit_tile_pos + Vector2i(0, -y), FLOOR_TILE_INDEX, Vector2i.ZERO)
#				previous_room_tilemap.set_cell(0, exit_tile_pos + Vector2i(1, -y), RIGHT_WALL_TILE_INDEX, Vector2i.ZERO)
#
#			var room_tilemap: TileMap = room.get_node("TileMap")
#			room.position = previous_room_door.global_position + Vector2.UP * room_tilemap.get_used_rect().size.y * TILE_SIZE + Vector2.UP * (1 + corridor_height) * TILE_SIZE + Vector2.LEFT * room_tilemap.local_to_map(room.get_node("Entrance/Position2D2").position).x * TILE_SIZE
#
#		add_child(room)
#		previous_room = room


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
		await get_tree().create_timer(1.5).timeout

	var delaunay_astar: AStar2D = AStar2D.new()
	for i in room_centers.size():
		delaunay_astar.add_point(i, room_centers[i])
	for i in delaunay_indices.size() - 1:
		delaunay_astar.connect_points(delaunay_indices[i], delaunay_indices[i+1])

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

#	for i in mst_astar.get_point_count():
#		print(str(i) + "  " + str(mst_astar.get_point_connections(i)))

	# print(astar.get_id_path(rooms.find(start_room), rooms.find(end_room)))

	if debug:
		queue_redraw()
		await get_tree().process_frame
		await get_tree().create_timer(1.5).timeout

	for id in mst_astar.get_point_count():
		for connection_with in mst_astar.get_point_connections(id):
			var dif: Vector2i = room_centers[connection_with] - room_centers[id]
			if dif.x < TILE_SIZE * 3:
				pass
			mst_astar.disconnect_points(id, connection_with)



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


func _get_random_point_in_circle(radius: float) -> Vector2:
	var t: float = 2 * PI * randf()
	var u: float = randf() + randf()
	var r = null
	if u > 1:
		r = 2 - u
	else:
		r = u

	return Vector2(radius * r * cos(t), radius * r * sin(t))
