class_name Rooms extends Node2D

const BIOMES_FOLDER_PATH: String = "res://Rooms/Biomes/"

const TILE_SIZE: int = 16
const MIN_SEPARATION_BETWEEN_ENTRIES: int = TILE_SIZE * 2
static var ATLAS_ID: int

const FLOOR_TILE_COORDS: Array[Vector2i] = [Vector2i(3, 1), Vector2i(5, 2), Vector2i(5, 3)]
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

enum RoomConnection {
	NONE,
	VERTICAL,
	HORIZONTAL,
	L_315,
	L_45,
	L_225,
	L_135,
}

var spawn_shape: SpawnShape = CircleSpawnShape.new(100)

var rooms: Array[DungeonRoom] = []
var start_room: DungeonRoom
#var end_room: DungeonRoom
var mst_astar: AStar2D = null
# DEBUG
@onready var debug: bool = get_parent().debug
@export var debug_check_entry_positions: bool = false
@export var use_delaunay: bool = false
@export var pause_between_steps: float = 1.2
@export var add_tile_group_time: float = 0.0003
@export var add_light_pause: float = 0.2
var room_centers: Array[Vector2] = []
var delaunay_indices: PackedInt32Array
# Tengo que declarar esto aquí porque esta wea culiada no me deja dibujar fuera de _draw
var vertical_corridor_rect: Rect2
var vertical_corridor_1_rect: Rect2
var vertical_corridor_2_rect: Rect2
var horizontal_corridor_rect: Rect2
var horizontal_corridor_1_rect: Rect2
var horizontal_corridor_2_rect: Rect2

var room_rect: Rect2

var visited_rooms: Array[DungeonRoom] = []
signal room_visited(room: DungeonRoom)

@export var num_levels: int = 5

var map_rect: Rect2 = Rect2(0, 0, 0, 0)
var fog_image: Image = Image.new()
const FOG_PADDING: int = 128

@onready var reload_on_eror: bool = get_parent().reload_on_generation_eror

@onready var fog_sprite: Sprite2D = $"../FogSprite"

# @onready var player: CharacterBody2D = get_parent().get_node("Player")

@onready var corridor_tile_map: TileMap = get_node("CorridorTileMap")


func _ready() -> void:
	set_physics_process(false)

	ATLAS_ID = SavedData.get_biome_conf().corridor_atlas_id

	if debug:
		corridor_tile_map.z_index = 1
		var corridor_material: CanvasItemMaterial = CanvasItemMaterial.new()
		corridor_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		corridor_tile_map.material = corridor_material
	else:
		corridor_tile_map.z_index = 0
		corridor_tile_map.material = null


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_S:
			debug_check_entry_positions = !debug_check_entry_positions
			queue_redraw()


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
		var ok: bool = await _create_corridors()
		if not ok:
			return
		_create_fog()
		start_room._on_player_entered_room()
		#start_room._on_player_entered_room()


func _get_rooms(type: String) -> PackedStringArray:
	var room_paths: PackedStringArray

	var overwrite_room_paths: PackedStringArray = PackedStringArray(SavedData.get_overwrite_room_paths(type.replace("/", "_").to_lower()))
	if not overwrite_room_paths.is_empty():
		room_paths = overwrite_room_paths
	else:
		if type.to_lower().begins_with("end"):
			room_paths = SavedData.get_volatile_room_paths(SavedData.run_stats.biome, "end", type.split("/")[1])
		else:
			room_paths = SavedData.get_volatile_room_paths(SavedData.run_stats.biome, type)

		var rooms_dir: DirAccess = DirAccess.open(BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/" + type)
		if room_paths.is_empty() and rooms_dir == null:
			push_error("Error opening " + BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/" + type + "!")
			return []
		if rooms_dir:
			for file in rooms_dir.get_files():
				room_paths.push_back(BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/" + type + "/" + file)

		for i in range(room_paths.size()-1, -1, -1):
			room_paths[i] = room_paths[i].trim_suffix(".remap")
			var room_scene_state: SceneState = load(room_paths[i]).get_state()
			for ii in room_scene_state.get_node_property_count(0):
				if room_scene_state.get_node_property_name(0, ii) == "levels":
					var levels: String = room_scene_state.get_node_property_value(0, ii)
					if (levels.length() == 1 and levels.is_valid_int() and int(levels) != SavedData.run_stats.level) or (levels.length() >= 3 and levels.find("-") != -1 and (int(levels.split("-")[0]) > SavedData.run_stats.level or int(levels.split("-")[1]) < SavedData.run_stats.level)):
						room_paths.remove_at(i)
					break

	for ignored_room_path in SavedData.get_ignored_rooms():
		if room_paths.has(ignored_room_path):
			room_paths.remove_at(room_paths.find(ignored_room_path))

	return room_paths


func _get_end_rooms() -> Array[PackedStringArray]:
	var end_rooms_dir: DirAccess = DirAccess.open(BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/End")
	if end_rooms_dir == null:
		printerr("Error opening " + BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/End!")
		return []

	var end_rooms: Array[PackedStringArray] = []
	for dir in end_rooms_dir.get_directories():
		end_rooms.push_back(_get_rooms("End/" + dir))

	# Discard rooms of other levels
#	for i in range(end_rooms.size()-1, -1, -1):
#		var end_room_array: PackedStringArray = end_rooms[i]
#		for ii in range(end_room_array.size()-1, -1, -1):
#			var room_name: String = end_room_array[ii]
##			if room_name.get_file().begins_with("Level") and not room_name.get_file().begins_with("Level" + str(SavedData.run_stats.level)):
##				end_room_array.remove_at(ii)
##			else:
#			end_room_array[ii] = end_rooms_dir.get_directories()[i] + "/" + room_name

	return end_rooms


func spawn_rooms() -> void:
	var overwrite_spawn_shape: SpawnShape = SavedData.get_overwrite_spawn_shape()
	if overwrite_spawn_shape:
		spawn_shape = overwrite_spawn_shape

	var room_paths: Dictionary = {
		"start": _get_rooms("Start"),
		"combat": _get_rooms("Combat"),
		"special": _get_rooms("Special"),
		"end": _get_end_rooms(),
	}

#	room_paths.start.append_array(SavedData.get_volatile_room_paths(SavedData.run_stats.biome, "start"))
#	room_paths.combat.append_array(SavedData.get_volatile_room_paths(SavedData.run_stats.biome, "combat"))
#	room_paths.special.append_array(SavedData.get_volatile_room_paths(SavedData.run_stats.biome, "special"))
#	for end_to in room_paths.end:
#		room_paths.end[end_to].append_array(SavedData.get_volatile_room_paths(SavedData.run_stats.biome, "special"))

	# print(room_paths)
	start_room = load(room_paths.start[randi() % room_paths.start.size()]).instantiate()
	rooms.push_back(start_room)

	var end_rooms: Array[DungeonRoom] = []
	for array in room_paths.end:
		if array.is_empty():
			continue
		var end_room: DungeonRoom = load(array[randi() % array.size()]).instantiate()
		end_rooms.push_back(end_room)
		rooms.push_back(end_room)

	if end_rooms.is_empty():
		push_error("No end rooms for this level. Make sure you put the rooms on the correct folder, a subfolder of the 'End' folder")

	#var inter_rooms: Array[PackedScene] = INTERMEDIATE_ROOMS.duplicate(true)
	#inter_rooms.append_array(SavedData.custom_rooms)
	var num_special_rooms: int = SavedData.get_num_rooms("special")
	for i in num_special_rooms:
		var random_speacial_room_path: String = room_paths.special[randi() % room_paths.special.size()]
		rooms.push_back(load(random_speacial_room_path).instantiate())
		room_paths.special.remove_at(room_paths.special.find(random_speacial_room_path)) # So the same special room is not spawned 2 times
		if room_paths.special.is_empty() and (i+1) < num_special_rooms:
			if debug:
				print_rich("[color=yellow]" + str(num_special_rooms) + " special rooms should have spawned, but only " + str(i+1) + " did, since there are not enough special rooms[/color]")
			break

	var num_combat_rooms: int = SavedData.get_num_rooms("combat")
	for i in num_combat_rooms:
		#rooms.push_back(INTERMEDIATE_ROOMS[0].instantiate())
		rooms.push_back(load(room_paths.combat[randi() % room_paths.combat.size()]).instantiate())

	for room in rooms:
		room.name += "_" + str(rooms.find(room))
		room.player_entered.connect(func():
			visited_rooms.push_back(room)
			room_visited.emit(room)
		)
		call_deferred("add_child", room)
	await get_tree().process_frame
	await get_tree().process_frame

	#start_room._on_player_entered_room()
#	var start_room_pos: Vector2 = start_room.get_random_circle_spawn_point(SPAWN_CIRCLE_RADIUS)
#	rooms[0].float_position = start_room_pos # rooms[0] es la habitación de spawn
#	rooms[1].float_position = start_room_pos * -1 # rooms[1] es la habitación de salida
	for room in rooms:
		# Ya que ya hemos posicionado start y end antes
		#if not room in [start_room, end_room]:
		room.float_position = room.get_random_spawn_point(spawn_shape) - room.vector_to_center
#		if room.name.begins_with("Boss"):
#			print(room.vector_to_center)
#			print(room.float_position)
		# add_child(room)
		if debug:
			room.get_node("DebugRoomId").text = str(rooms.find(room))

	# return
	set_physics_process(true)


func _create_corridors() -> bool:
	#var room_centers: Array[Vector2] = []
	for i in rooms.size():
		room_centers.push_back(rooms[i].position + rooms[i].vector_to_center)
		if debug:
			print("Room " + str(i) + " center position: " + str(room_centers[i]))

	var initial_astar: AStar2D = AStar2D.new()

	if use_delaunay:
		if debug:
			print_rich("[b]--- Rooms: creating delaunay ---[/b]")
		delaunay_indices = Geometry2D.triangulate_delaunay(room_centers)
		#print(delaunay_indices)
		#print(room_centers)
		if debug:
			print("Delaunay: " + str(delaunay_indices))

	if debug:
		queue_redraw()
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	if use_delaunay:
		for i in room_centers.size():
			initial_astar.add_point(i, room_centers[i])
		for i in delaunay_indices.size() / 3.0:
			i = i * 3
			initial_astar.connect_points(delaunay_indices[i], delaunay_indices[i+1])
			initial_astar.connect_points(delaunay_indices[i+1], delaunay_indices[i+2])
			initial_astar.connect_points(delaunay_indices[i+2], delaunay_indices[i])
	else:
		# Connect each room with all the others
		for i in room_centers.size():
			initial_astar.add_point(i, room_centers[i])
		for i in room_centers.size():
			for j in room_centers.size():
				if i == j:
					continue
				initial_astar.connect_points(i, j)


	var overwrite_connections: Array = SavedData.get_overwrite_connections()

	mst_astar = AStar2D.new()
	mst_astar.add_point(mst_astar.get_available_point_id(), room_centers[0])
	initial_astar.set_point_disabled(0)

	if debug:
		print_rich("[b]--- Rooms: creating mst ---[/b]")
		print("initial_astar connections (between indices, not room ids):")
		for i in initial_astar.get_point_count():
			print("" + str(i) + ": " + str(initial_astar.get_point_connections(i)))
	# We start with 1 because we already have added the room 0
	for i in range(1, initial_astar.get_point_count()):
		var min_room_connection: RoomConnection = RoomConnection.NONE
		var min_dist: float = INF  # Minimum distance found so far
		var min_p: Vector2  # Position of that node
		#var p = null  # Current position
		var first_room_id: int = -1
		# Loop through the points in the path
		for id in mst_astar.get_point_ids():
			if debug:
				print("Checking room " + str(id) + " neighbours")
			var point: Vector2 = mst_astar.get_point_position(id)
			# Loop through the remaining nodes in the given array
			#print(initial_astar.get_point_count())
			for j in initial_astar.get_point_count():
				if initial_astar.is_point_disabled(j):
					if debug:
						print_rich("\t[color=yellow]Point " + str(j) + " is disabled[/color]")
					continue

				var point2: Vector2 = initial_astar.get_point_position(j)
				if debug:
					print_rich("\tChecking room " + str(room_centers.find(point2)) + "")

				if initial_astar.get_point_connections(room_centers.find(point)).has(j):
					if point.distance_to(point2) < min_dist:
						if not overwrite_connections.is_empty():
							var block_connection: bool = true
							for connection in overwrite_connections:
								if (connection[0] == id and connection[1] == room_centers.find(point2)) or (connection[0] == room_centers.find(point2) and connection[1] == id):
									block_connection = false
									break
							if block_connection:
								if debug:
									print_rich("\t[color=yellow]Connection between " + str(id) + " and " + str(room_centers.find(point2)) +  " is not possible because the connections are overwritten[/color]")
								continue
						var room_connection: RoomConnection = await _is_connection_possible(id, room_centers.find(point2))
						if not room_connection:
							if debug:
								print_rich("\t\t[color=yellow]No available connection to " + str(j) + "[/color]")
							continue
						min_room_connection = room_connection
						first_room_id = id
						min_dist = point.distance_to(point2)
						min_p = point2
						if debug:
							print_rich("\t[color=green]Available connection to " + str(j) + ": " + RoomConnection.keys()[room_connection] + "[/color]")
						#p = point
					else:
						if debug:
							print_rich("\t\t[color=yellow]Rooms " + str(room_centers.find(point)) + " and " + str(room_centers.find(point2)) + " are to close[/color]")
				else:
					if debug:
						print_rich("\t\t[color=yellow]initial_astar does not have any connections between room " + str(room_centers.find(point)) + " and " + str(room_centers.find(point2)) + "[/color]")

		if first_room_id == -1:
			#assert(false)
			push_error("first_room_id is null. There are no more possibles connections but there is some room/rooms that are not connected yet")
			if reload_on_eror:
				owner.reload_generation("Could not connect all rooms")
				return false
			continue
		var n: int = room_centers.find(min_p)
		mst_astar.add_point(n, min_p)
		mst_astar.connect_points(first_room_id, n)

		initial_astar.set_point_disabled(room_centers.find(min_p))
		if min_room_connection:
			await _create_corridor_between_rooms(first_room_id, n, min_room_connection)
		#rooms_not_used.remove_at(rooms_not_used.find(min_p))
		if debug:
			print("")

	if debug:
		queue_redraw()
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	if overwrite_connections.is_empty():
	# Añadimos alguna conexion extra
		if debug:
			print_rich("[b]--- Rooms: Adding extra connections to mst ---[/b]")
		for id in initial_astar.get_point_count():
			initial_astar.set_point_disabled(id, false)
		var points_that_could_be_connected: Array[Array] = []
		for id in initial_astar.get_point_count():
			for id2 in range(id + 1, initial_astar.get_point_count()):
				# print(str(id) + ": " + str(initial_astar.get_point_connections(id)))
				if initial_astar.get_point_connections(id).has(id2) and not mst_astar.get_point_connections(id).has(id2) and not points_that_could_be_connected.has([id, id2]) and not points_that_could_be_connected.has([id2, id]):
					points_that_could_be_connected.push_back([id, id2])
		if debug:
			print("Connections not used after mst: " + str(points_that_could_be_connected))

		var number_of_extra_connections: int = (round(rooms.size() - 1) * SavedData.get_biome_conf().extra_connections)
		if debug:
			print("Desired number of extra connections: " + str(number_of_extra_connections))
		var i: int = number_of_extra_connections
		while i > 0 and not points_that_could_be_connected.is_empty():
			var rand: int = randi() % points_that_could_be_connected.size()
			var room_connection: RoomConnection = await _is_connection_possible(points_that_could_be_connected[rand][0], points_that_could_be_connected[rand][1])
			if room_connection:
				await _create_corridor_between_rooms(points_that_could_be_connected[rand][0], points_that_could_be_connected[rand][1], room_connection)
				mst_astar.connect_points(points_that_could_be_connected[rand][0], points_that_could_be_connected[rand][1])
				i -= 1
			points_that_could_be_connected.remove_at(rand)
		if debug:
			print("")

	if debug:
		queue_redraw()
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	#await _add_floor_tiles()

	# await add_tiles.call()
	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	# MODIFY TILES BEFORE APPLYING THE AUTOTILE
	# To fill 1 tile gaps
	for cell_pos in corridor_tile_map.get_used_cells(0):
		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT) == Vector2i(-1, -1) and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT * 2) in FLOOR_TILE_COORDS and corridor_tile_map.get_cell_atlas_coords(0, cell_pos) in FLOOR_TILE_COORDS:
			corridor_tile_map.set_cell(0, cell_pos + Vector2i.LEFT, ATLAS_ID, FLOOR_TILE_COORDS[0])
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos) in FLOOR_TILE_COORDS and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN * 2) in FLOOR_TILE_COORDS:
			corridor_tile_map.set_cell(0, cell_pos + Vector2i.DOWN, ATLAS_ID, FLOOR_TILE_COORDS[0])
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout

	# CORRIDOR WALLS
#	corridor_tile_map.set_cells_terrain_connect(0, corridor_tile_map.get_used_cells(0), 0, 0 if ATLAS_ID == 40 else 1)
	for cell_pos in corridor_tile_map.get_used_cells(0):
		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT) == Vector2i(-1, -1):
			corridor_tile_map.set_cell(1, cell_pos + Vector2i.LEFT, ATLAS_ID, LEFT_WALL_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.RIGHT) == Vector2i(-1, -1):
			corridor_tile_map.set_cell(1, cell_pos + Vector2i.RIGHT, ATLAS_ID, RIGHT_WALL_COOR)

		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.UP) == Vector2i(-1, -1):
			corridor_tile_map.erase_cell(1, cell_pos + Vector2i.UP)
			corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, FULL_WALL_COORDS[randi() % FULL_WALL_COORDS.size()])

	var entry_cells: Array[Vector2i] = []
	for room in rooms:
		for dir in [DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.DOWN]:
			var entries: Array[Node] = room.get_entries(dir)
			for entry in entries:
				var entry_pos: Vector2i = corridor_tile_map.local_to_map(entry.global_position)
				if corridor_tile_map.get_cell_atlas_coords(0, entry_pos + [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN][dir]) in FLOOR_TILE_COORDS:
					room.mark_entry_as_used(entry)
					for pos_node in entry.get_children():
						var cell: Vector2i = corridor_tile_map.local_to_map(pos_node.global_position)
						corridor_tile_map.erase_cell(0, cell)
						corridor_tile_map.erase_cell(1, cell)
						entry_cells.push_back(cell)

	for cell_pos in corridor_tile_map.get_used_cells(0):
		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos) in FULL_WALL_COORDS:
			if corridor_tile_map.get_cell_atlas_coords(1, cell_pos + Vector2i.UP) == RIGHT_WALL_COOR:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_LEFT_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(1, cell_pos + Vector2i.UP) == LEFT_WALL_COOR:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_RIGHT_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.RIGHT) in FLOOR_TILE_COORDS and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i(1, -1)) in FULL_WALL_COORDS:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_RIGHT_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP * 2, ATLAS_ID, UPPER_WALL_LEFT_CORNER_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT) in FLOOR_TILE_COORDS and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i(-1, -1)) in FULL_WALL_COORDS:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_LEFT_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP * 2, ATLAS_ID, UPPER_WALL_RIGHT_CORNER_COOR)
			else:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_COOR)

			if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.RIGHT) == Vector2i(-1, -1) and not entry_cells.has(cell_pos + Vector2i.RIGHT + Vector2i.DOWN):
				corridor_tile_map.set_cell(1, cell_pos + Vector2i.RIGHT, ATLAS_ID, RIGHT_WALL_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.RIGHT + Vector2i.UP, ATLAS_ID, UPPER_WALL_RIGHT_CORNER_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT) == Vector2i(-1, -1) and not entry_cells.has(cell_pos + Vector2i.LEFT + Vector2i.DOWN):
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.LEFT, ATLAS_ID, LEFT_WALL_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.LEFT + Vector2i.UP, ATLAS_ID, UPPER_WALL_LEFT_CORNER_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos) in FLOOR_TILE_COORDS and not corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) in FLOOR_TILE_COORDS:
			if corridor_tile_map.get_cell_atlas_coords(1, cell_pos + Vector2i.DOWN) == RIGHT_WALL_COOR:
				corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, LEFT_BOTTOM_WALL_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(1, cell_pos + Vector2i.DOWN) == LEFT_WALL_COOR:
				corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, RIGHT_BOTTOM_WALL_COOR)
			else:
				corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, BOTTOM_WALL_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(1, cell_pos) == LEFT_WALL_COOR and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) == Vector2i(-1, -1) and not entry_cells.has(cell_pos + Vector2i.ONE):
			corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, LAST_LEFT_WALL_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(1, cell_pos) == RIGHT_WALL_COOR and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) == Vector2i(-1, -1) and not entry_cells.has(cell_pos + Vector2i.DOWN + Vector2i.LEFT):
			corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, LAST_RIGHT_WALL_COOR)

		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	for room in rooms:
		room.add_doors_and_walls(corridor_tile_map)
		room.generate_room_white_image()

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	await _add_lights()

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	$"../UI/MiniMap".set_up()
	_divide_corridor_tile_map()

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps * 2).timeout

	generation_completed.emit()

	return true


func _add_lights() -> void:
	var TIKI_TORCH_SCENE: PackedScene = load("res://Rooms/Biomes/Forest/TikiTorch.tscn")

	for cell in corridor_tile_map.get_used_cells(0):
		if corridor_tile_map.get_cell_atlas_coords(0, cell) == UPPER_WALL_COOR:
			if cell.x % 8 == 0 :
				var light: Node2D = TIKI_TORCH_SCENE.instantiate()
				light.position = corridor_tile_map.map_to_local(cell) + Vector2.DOWN * 27
				add_child(light)
				if debug:
					await get_tree().create_timer(add_light_pause).timeout
		elif corridor_tile_map.get_cell_atlas_coords(1, cell) == LEFT_WALL_COOR:
			@warning_ignore("integer_division")
			if cell.y % 8 == 0 if SavedData.get_vertical_corridor_symmetric_lights() else (cell.y % 14) == 7:
				var light: Node2D = TIKI_TORCH_SCENE.instantiate()
				light.position = corridor_tile_map.map_to_local(cell) + Vector2.RIGHT * 10
				add_child(light)
				if debug:
					await get_tree().create_timer(add_light_pause).timeout
		elif corridor_tile_map.get_cell_atlas_coords(1, cell) == RIGHT_WALL_COOR:
			@warning_ignore("integer_division")
			if cell.y % 8 == 0 if SavedData.get_vertical_corridor_symmetric_lights() else (cell.y % 14) == 0:
				var light: Node2D = TIKI_TORCH_SCENE.instantiate()
				light.position = corridor_tile_map.map_to_local(cell) + Vector2.LEFT * 10
				add_child(light)
				if debug:
					await get_tree().create_timer(add_light_pause).timeout


func _create_fog() -> void:
	for room in rooms:
		map_rect = map_rect.merge(room.get_rect())
	map_rect.position -= Vector2.ONE * FOG_PADDING
	map_rect.size += Vector2.ONE * FOG_PADDING * 2
	fog_sprite.position = map_rect.position
	@warning_ignore("narrowing_conversion")
	fog_image = Image.create(map_rect.size.x, map_rect.size.y, false, Image.FORMAT_RGBAH)
	fog_image.fill(Color.BLACK)

	#fog_sprite.texture = ImageTexture.create_from_image(fog_image)

	while is_instance_valid(Globals.player):
		var light: Image = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/light_fire.png").get_image()
		light.convert(Image.FORMAT_RGBAH)
		fog_image.blend_rect(light, Rect2(Vector2.ZERO, light.get_size()), Globals.player.position - map_rect.position - light.get_size()/2.0)
		fog_sprite.texture = ImageTexture.create_from_image(fog_image)
		await get_tree().create_timer(0.2).timeout


func clear_room_fog(at_pos: Vector2, room_white_image: Image) -> void:
#	for tile_cell in tilemap.get_used_cells(0):
#		var rect: Rect2 = Rect2(tilemap.get_parent().position + Vector2(tile_cell * Rooms.TILE_SIZE), Vector2.ONE * Rooms.TILE_SIZE)
#		@warning_ignore("narrowing_conversion")
#		var image: Image = Image.create(rect.size.x, rect.size.y, false, Image.FORMAT_RGBAH)
#		image.fill(Color.WHITE)
#		#var light: Image = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/light_fire.png").get_image()
#		#light.convert(Image.FORMAT_RGBAH)
#		var image_size: Vector2 = image.get_size()
	fog_image.blend_rect(room_white_image, Rect2(Vector2.ZERO, room_white_image.get_size()), at_pos - map_rect.position)
	fog_sprite.texture = ImageTexture.create_from_image(fog_image)


func _create_corridor_between_rooms(id: int, connection_with: int, room_connection: RoomConnection) -> void:
	var dif: Vector2 = room_centers[connection_with] - room_centers[id]
	match room_connection:
		RoomConnection.VERTICAL:
			var entries: Array[Node] = await _check_entry_positions_vertical_corridor(id if dif.y > 0 else connection_with, connection_with if dif.y > 0 else id, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.UP)
#			var above: Node = rooms[id if dif.y > 0 else connection_with].get_random_entry(DungeonRoom.EntryDirection.DOWN)
#			var below: Node = rooms[connection_with if dif.y > 0 else id].get_random_entry(DungeonRoom.EntryDirection.UP, above)
			await _create_vertical_corridor(entries[0], entries[1])
#			rooms[id if dif.y > 0 else connection_with].mark_entry_as_used(entries[0])
#			rooms[connection_with if dif.y > 0 else id].mark_entry_as_used(entries[1])
		RoomConnection.HORIZONTAL:
			var entries: Array[Node] = await _check_entry_positions_horizontal_corridor(id if dif.x > 0 else connection_with, connection_with if dif.x > 0 else id, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.LEFT)
			var left: Node = entries[0] if entries[0].global_position.x < entries[1].global_position.x else entries[1]
			var right: Node = entries[1] if entries[0].global_position.x < entries[1].global_position.x else entries[0]
			await _create_horizontal_corridor(left, right)
#			rooms[id if dif.x > 0 else connection_with].mark_entry_as_used(left)
#			rooms[connection_with if dif.x > 0 else id].mark_entry_as_used(right)
		RoomConnection.L_315:
			var directions: Array[Array] = [[DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.UP], [DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.LEFT]]
			await _decide_direction_and_create_l_corridor(id, connection_with, directions)
		RoomConnection.L_45:
			var directions: Array[Array] = [[DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.DOWN], [DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.LEFT]]
			await _decide_direction_and_create_l_corridor(id, connection_with, directions)
		RoomConnection.L_225:
			var directions: Array[Array] = [[DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.UP], [DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.RIGHT]]
			await _decide_direction_and_create_l_corridor(id, connection_with, directions)
		RoomConnection.L_135:
			var directions: Array[Array] = [[DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.DOWN], [DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.RIGHT]]
			await _decide_direction_and_create_l_corridor(id, connection_with, directions)


func _decide_direction_and_create_l_corridor(id: int, connection_with: int, directions: Array) -> void:
	var rand: int = randi() % 2
	var entries: Array[Node] = await _check_entry_positions_l_corridor(id, connection_with, directions[rand][0], directions[rand][1])
	if not entries.is_empty():
		await _create_l_corridor(entries[0], entries[1], directions[rand][0], directions[rand][1])
#		rooms[id].mark_entry_as_used(entries[0])
#		rooms[connection_with].mark_entry_as_used(entries[1])
	else:
		rand = (int(rand == 0))
		entries = await _check_entry_positions_l_corridor(id, connection_with, directions[rand][0], directions[rand][1])
		assert(not entries.is_empty())
		await _create_l_corridor(entries[0], entries[1], directions[rand][0], directions[rand][1])
#		rooms[id].mark_entry_as_used(entries[0])
#		rooms[connection_with].mark_entry_as_used(entries[1])


#func _add_floor_tiles() -> void:
#	for id in mst_astar.get_point_count():
#		for connection_with in mst_astar.get_point_connections(id):
#			var dif: Vector2 = room_centers[connection_with] - room_centers[id]
#			if debug:
#				print("Connecting " + str(id) + " with " + str(connection_with) + "...")
#				print("\tdif is " + str(dif) + " pixels")
#			if abs(dif.x) < TILE_SIZE * 8 and rooms[id if dif.y > 0 else connection_with].has_entry(DungeonRoom.EntryDirection.DOWN) and rooms[connection_with if dif.y > 0 else id].has_entry(DungeonRoom.EntryDirection.UP):
#				var above: Node = rooms[id if dif.y > 0 else connection_with].get_random_entry(DungeonRoom.EntryDirection.DOWN)
#				var below: Node = rooms[connection_with if dif.y > 0 else id].get_random_entry(DungeonRoom.EntryDirection.UP)
#				await _create_vertical_corridor(above, below)
#			elif abs(dif.y) < TILE_SIZE * 8 and rooms[id if dif.x > 0 else connection_with].has_entry(DungeonRoom.EntryDirection.RIGHT) and rooms[connection_with if dif.x > 0 else id].has_entry(DungeonRoom.EntryDirection.LEFT):
#				var left: Node = rooms[id if dif.x > 0 else connection_with].get_random_entry(DungeonRoom.EntryDirection.RIGHT)
#				var right: Node = rooms[connection_with if dif.x > 0 else id].get_random_entry(DungeonRoom.EntryDirection.LEFT)
#				await _create_horizontal_corridor(left, right)
#			else:
#				if dif.x > 0 and dif.y > 0:
#					var directions: Array[Array] = [[DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.UP], [DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.LEFT]]
#					await _analyze_and_create_l_corridor(id, connection_with, directions)
#				elif dif.x > 0 and dif.y < 0:
#					var directions: Array[Array] = [[DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.DOWN], [DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.LEFT]]
#					await _analyze_and_create_l_corridor(id, connection_with, directions)
#				elif dif.x < 0 and dif.y > 0:
#					var directions: Array[Array] = [[DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.UP], [DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.RIGHT]]
#					await _analyze_and_create_l_corridor(id, connection_with, directions)
#				else: # dif.x < 0 and dif.y < 0
#					var directions: Array[Array] = [[DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.DOWN], [DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.RIGHT]]
#					await _analyze_and_create_l_corridor(id, connection_with, directions)
#
#			mst_astar.disconnect_points(id, connection_with)


func _is_connection_possible(id: int, connection_with: int) -> RoomConnection:
	if debug:
		print("\tChecking connection between " + str(id) + " " + str(connection_with) + "...")
	var dif: Vector2 = room_centers[connection_with] - room_centers[id]
	if abs(dif.x) < TILE_SIZE * 8 and not (await _check_entry_positions_vertical_corridor(id if dif.y > 0 else connection_with, connection_with if dif.y > 0 else id, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.UP)).is_empty():
		if debug:
			print_rich("\t\t[color=green]Vertical connection is possible[/color]")
		return RoomConnection.VERTICAL
	elif abs(dif.y) < TILE_SIZE * 8 and not (await _check_entry_positions_horizontal_corridor(id if dif.x > 0 else connection_with, connection_with if dif.x > 0 else id, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.LEFT)).is_empty():
		if debug:
			print_rich("\t\t[color=green]Horizontal connection is possible[/color]")
		return RoomConnection.HORIZONTAL
	else:
		if dif.x > 0 and dif.y > 0:
			if not (await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.UP)).is_empty() or not (await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.LEFT)).is_empty():
				if debug:
					print_rich("\t\t[color=green]L connection is possible through if 0[/color]")
				return RoomConnection.L_315
		elif dif.x > 0 and dif.y < 0:
			if not (await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.DOWN)).is_empty() or not (await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.LEFT)).is_empty():
				if debug:
					print_rich("\t\t[color=green]L connection is possible through if 1[/color]")
				return RoomConnection.L_45
		elif dif.x < 0 and dif.y > 0:
			if not (await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.UP)).is_empty() or not (await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.RIGHT)).is_empty():
				if debug:
					print_rich("\t\t[color=green]L connection is possible through if 2[/color]")
				return RoomConnection.L_225
		else: # dif.x < 0 and dif.y < 0
			if not (await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.DOWN)).is_empty() or not (await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.RIGHT)).is_empty():
				if debug:
					print_rich("\t\t[color=green]L connection is possible through if 3[/color]")
				return RoomConnection.L_135

	if not (await _check_entry_positions_vertical_corridor(id, connection_with, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.UP)).is_empty():
		if debug:
			print_rich("\t\t[color=green]Vertical connection is possible[/color]")
		return RoomConnection.VERTICAL
	elif not (await _check_entry_positions_vertical_corridor(id, connection_with, DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.DOWN)).is_empty():
		if debug:
			print_rich("\t\t[color=green]Vertical connection is possible[/color]")
		return RoomConnection.VERTICAL
	elif not (await _check_entry_positions_horizontal_corridor(id, connection_with, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.LEFT)).is_empty():
		if debug:
			print_rich("\t\t[color=green]Horizontal connection is possible[/color]")
		return RoomConnection.HORIZONTAL
	elif not (await _check_entry_positions_horizontal_corridor(id, connection_with, DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.RIGHT)).is_empty():
		if debug:
			print_rich("\t\t[color=green]Horizontal connection is possible[/color]")
		return RoomConnection.HORIZONTAL

	if debug:
		print_rich("\t[color=yellow]It's not possible to connect the rooms[/color]")
	return RoomConnection.NONE


#func _analyze_and_create_l_corridor(id: int, connection_with: int, directions: Array[Array]) -> void:
#	var rand: int = randi() % 2
#	if rooms[id].has_entry(directions[rand][0]) and rooms[connection_with].has_entry(directions[rand][1]) and await _check_entry_positions_l_corridor(id, connection_with, directions[rand][0], directions[rand][1]):
#		await _create_l_corridor(rooms[id].get_random_entry(directions[rand][0]), rooms[connection_with].get_random_entry(directions[rand][1]), directions[rand][0], directions[rand][1])
#	else:
#		rand = (int(rand == 0))
#		if rooms[id].has_entry(directions[rand][0]) and rooms[connection_with].has_entry(directions[rand][1]) and await _check_entry_positions_l_corridor(id, connection_with, directions[rand][0], directions[rand][1]):
#			await _create_l_corridor(rooms[id].get_random_entry(directions[rand][0]), rooms[connection_with].get_random_entry(directions[rand][1]), directions[rand][0], directions[rand][1])
#		else:
#			if rooms[id].has_entry(DungeonRoom.EntryDirection.DOWN) and rooms[connection_with].has_entry(DungeonRoom.EntryDirection.UP) and  await _check_entry_positions_vertical_corridor(id, connection_with, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.UP):
#				await _create_vertical_corridor(rooms[id].get_random_entry(DungeonRoom.EntryDirection.DOWN), rooms[connection_with].get_random_entry(DungeonRoom.EntryDirection.UP))
#			elif rooms[id].has_entry(DungeonRoom.EntryDirection.UP) and rooms[connection_with].has_entry(DungeonRoom.EntryDirection.DOWN) and  await _check_entry_positions_vertical_corridor(id, connection_with, DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.DOWN):
#				await _create_vertical_corridor(rooms[connection_with].get_random_entry(DungeonRoom.EntryDirection.DOWN), rooms[id].get_random_entry(DungeonRoom.EntryDirection.UP))
#			elif rooms[id].has_entry(DungeonRoom.EntryDirection.RIGHT) and rooms[connection_with].has_entry(DungeonRoom.EntryDirection.LEFT) and  await _check_entry_positions_horizontal_corridor(id, connection_with, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.LEFT):
#				await _create_horizontal_corridor(rooms[id].get_random_entry(DungeonRoom.EntryDirection.RIGHT), rooms[connection_with].get_random_entry(DungeonRoom.EntryDirection.LEFT))
#			elif rooms[id].has_entry(DungeonRoom.EntryDirection.LEFT) and rooms[connection_with].has_entry(DungeonRoom.EntryDirection.RIGHT) and  await _check_entry_positions_horizontal_corridor(id, connection_with, DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.RIGHT):
#				await _create_horizontal_corridor(rooms[connection_with].get_random_entry(DungeonRoom.EntryDirection.RIGHT), rooms[id].get_random_entry(DungeonRoom.EntryDirection.LEFT))
#			else:
#				printerr("\tI have not been able to create a path between " + str(id) + " and " + str(connection_with))


func _check_entry_positions_vertical_corridor(id: int, connection_with: int, id_dir: DungeonRoom.EntryDirection, connection_with_dir: DungeonRoom.EntryDirection) -> Array[Node]:
	for i in 2:
		var ids: Array = [[id, connection_with], [connection_with, id]][i]
		var directions: Array = [[id_dir, connection_with_dir], [connection_with_dir, id_dir]][i]
		var entries1: Array[Node] = rooms[ids[0]].get_entries(directions[0]).duplicate()
		entries1.shuffle()
		var entries2: Array[Node] = rooms[ids[1]].get_entries(directions[1]).duplicate()
		entries2.shuffle()
		for entry in entries1:
			for other_entry in entries2:
				var connection_possible: bool = true
				if entry == null or other_entry == null:
					continue

				var id_entry_position: Vector2 = entry.get_children()[0].global_position
				var connection_with_entry_position: Vector2 = other_entry.get_children()[0].global_position

				const MIN_TILES_TO_MAKE_DESVIATION: int = 2
				var dis: float = id_entry_position.y - connection_with_entry_position.y
				var center: int = floor((dis) / 2.0)

				# print(dis)
				if abs(dis) < TILE_SIZE * 5 or (directions[0] == DungeonRoom.EntryDirection.UP and id_entry_position.y < connection_with_entry_position.y) or (directions[0] == DungeonRoom.EntryDirection.DOWN and id_entry_position.y > connection_with_entry_position.y):
					continue

				vertical_corridor_1_rect = Rect2(connection_with_entry_position, Vector2(TILE_SIZE * 4, center)).abs()
				vertical_corridor_2_rect = Rect2(id_entry_position, Vector2(TILE_SIZE * 4, center if dis < 0 else -center)).abs()
				#vertical_corridor_2_rect = Rect2(id_entry_position, Vector2(TILE_SIZE * 4, dis - center - MIN_TILES_TO_MAKE_DESVIATION + 1)).abs()
				horizontal_corridor_rect = Rect2(connection_with_entry_position + Vector2.DOWN * center + Vector2.UP * TILE_SIZE * 2, Vector2(id_entry_position.x - connection_with_entry_position.x, TILE_SIZE * 4)).abs()

				for room in rooms:
#					if room == rooms[ids[0]] or room == rooms[ids[1]]:
#						continue # Para que no detecta las habitaciones que se conectan, solo las otras

					room_rect = room.get_rect()
					# print("Room " + str(rooms.find(room)) + "  " + str(room_rect))

					if debug_check_entry_positions:
						queue_redraw()
						await get_tree().create_timer(0.6).timeout
					if (room != rooms[ids[1]] and room_rect.intersects(vertical_corridor_1_rect)) or (room != rooms[ids[0]] and room_rect.intersects(vertical_corridor_2_rect)) or room_rect.intersects(horizontal_corridor_rect):
						connection_possible = false

				if connection_possible:
					return [entry, other_entry]

	return []


func _check_entry_positions_horizontal_corridor(id: int, connection_with: int, id_dir: DungeonRoom.EntryDirection, connection_with_dir: DungeonRoom.EntryDirection) -> Array[Node]:
	for i in 2:
		var ids: Array = [[id, connection_with], [connection_with, id]][i]
		var directions: Array = [[id_dir, connection_with_dir], [connection_with_dir, id_dir]][i]
		var entries1: Array[Node] = rooms[ids[0]].get_entries(directions[0]).duplicate()
		entries1.shuffle()
		var entries2: Array[Node] = rooms[ids[1]].get_entries(directions[1]).duplicate()
		entries2.shuffle()
		for entry in entries1:
			for other_entry in entries2:
				var connection_possible: bool = true

				if entry == null or other_entry == null:
					continue

				var id_entry_position: Vector2 = entry.get_children()[0].global_position
				var connection_with_entry_position: Vector2 = other_entry.get_children()[0].global_position

				const MIN_TILES_TO_MAKE_DESVIATION: int = 2
				var dis: float = id_entry_position.x - connection_with_entry_position.x
				var center: int = floor((dis) / 2.0)

				if abs(dis) < TILE_SIZE * 4 or (directions[0] == DungeonRoom.EntryDirection.LEFT and id_entry_position.x < connection_with_entry_position.x) or (directions[0] == DungeonRoom.EntryDirection.RIGHT and id_entry_position.x > connection_with_entry_position.x):
					continue

				horizontal_corridor_1_rect = Rect2(connection_with_entry_position + Vector2.UP * TILE_SIZE * 2, Vector2(center, TILE_SIZE * 4))
				horizontal_corridor_2_rect = Rect2(connection_with_entry_position if connection_with_entry_position.x > id_entry_position.x else id_entry_position, Vector2((dis - center if connection_with_entry_position.x > id_entry_position.x else -dis + center) - (MIN_TILES_TO_MAKE_DESVIATION + 1) * TILE_SIZE, TILE_SIZE * 4))
				vertical_corridor_rect = Rect2((connection_with_entry_position if connection_with_entry_position.x > id_entry_position.x else id_entry_position) + Vector2.LEFT * center, Vector2(TILE_SIZE * 4, (id_entry_position.y - connection_with_entry_position.y) if connection_with_entry_position.x > id_entry_position.x else (connection_with_entry_position.y - id_entry_position.y)))

				for room in rooms:
#					if room == rooms[ids[0]] or room == rooms[ids[1]]:
#						continue # Para que no detecta las habitaciones que se conectan, solo las otras

					room_rect = room.get_rect()
					# print("Room " + str(rooms.find(room)) + "  " + str(room_rect))

					if debug_check_entry_positions:
						queue_redraw()
						await get_tree().create_timer(0.6).timeout
					if (room != rooms[ids[1]] and room_rect.intersects(horizontal_corridor_1_rect.abs())) or (room != rooms[ids[0]] and room_rect.intersects(horizontal_corridor_2_rect.abs())) or room_rect.intersects(vertical_corridor_rect.abs()):
						connection_possible = false

				if connection_possible:
					return [entry, other_entry]


#	if id == 4 and connection_with == 6:
#		queue_redraw()
#		await get_tree().create_timer(5).timeout

	return []


func _check_entry_positions_l_corridor(id: int, connection_with: int, id_dir: DungeonRoom.EntryDirection, connection_with_dir: DungeonRoom.EntryDirection) -> Array[Node]:
	for i in 2:
		var ids: Array = [[id, connection_with], [connection_with, id]][i]
		var directions: Array = [[id_dir, connection_with_dir], [connection_with_dir, id_dir]][i]
		var entries1: Array[Node] = rooms[ids[0]].get_entries(directions[0]).duplicate()
		entries1.shuffle()
		var entries2: Array[Node] = rooms[ids[1]].get_entries(directions[1]).duplicate()
		entries2.shuffle()
		for entry in entries1:
			for other_entry in entries2:
				var connection_possible: bool = true

				if entry == null or other_entry == null:
					continue

				var id_entry_position: Vector2 = entry.get_children()[0].global_position
				var connection_with_entry_position: Vector2 = other_entry.get_children()[0].global_position

			#	var vertical_corridor_rect: Rect2
			#	var horizontal_corridor_rect: Rect2
				if id_dir == DungeonRoom.EntryDirection.UP or id_dir == DungeonRoom.EntryDirection.DOWN:
					vertical_corridor_rect = Rect2(id_entry_position.x - 32, id_entry_position.y, TILE_SIZE * 4, connection_with_entry_position.y - id_entry_position.y)
					horizontal_corridor_rect = Rect2(connection_with_entry_position.x, connection_with_entry_position.y - 32, id_entry_position.x - connection_with_entry_position.x + TILE_SIZE, TILE_SIZE * 4)
				else:
					vertical_corridor_rect = Rect2(connection_with_entry_position.x - 32, connection_with_entry_position.y, TILE_SIZE * 4, id_entry_position.y - connection_with_entry_position.y)
					horizontal_corridor_rect = Rect2(id_entry_position.x, id_entry_position.y - 32, connection_with_entry_position.x - id_entry_position.x + TILE_SIZE, TILE_SIZE * 4)

				for room in rooms:
#					if room == rooms[id] or room == rooms[connection_with]:
#						continue # Para que no detecta las habitaciones que se conectan, solo las otras

					room_rect = room.get_rect()
					# print("Room " + str(rooms.find(room)) + "  " + str(room_rect))

					if debug_check_entry_positions:
						queue_redraw()
						await get_tree().create_timer(0.6).timeout
					if id_dir == DungeonRoom.EntryDirection.UP or id_dir == DungeonRoom.EntryDirection.DOWN:
						if (room != rooms[id] and room_rect.intersects(vertical_corridor_rect.abs())) or (room != rooms[connection_with] and room_rect.intersects(horizontal_corridor_rect.abs())):
							connection_possible = false
					else:
						if (room != rooms[connection_with] and room_rect.intersects(vertical_corridor_rect.abs())) or (room != rooms[id] and room_rect.intersects(horizontal_corridor_rect.abs())):
							connection_possible = false

				if id_dir == DungeonRoom.EntryDirection.RIGHT or connection_with_dir == DungeonRoom.EntryDirection.LEFT:
					if not id_entry_position.x < (connection_with_entry_position.x - MIN_SEPARATION_BETWEEN_ENTRIES):
						connection_possible = false
				else:
					if not connection_with_entry_position.x < (id_entry_position.x - MIN_SEPARATION_BETWEEN_ENTRIES):
						connection_possible = false
				if id_dir == DungeonRoom.EntryDirection.DOWN or connection_with_dir == DungeonRoom.EntryDirection.UP:
					if not id_entry_position.y < (connection_with_entry_position.y - MIN_SEPARATION_BETWEEN_ENTRIES):
						connection_possible = false
				else:
					if not connection_with_entry_position.y < (id_entry_position.y - MIN_SEPARATION_BETWEEN_ENTRIES):
						connection_possible = false

				if connection_possible:
					return [entry, other_entry]

	return []


# above and below are entries, with 2 children
func _create_vertical_corridor(above: Node, below: Node) -> void:
	assert(above.get_child_count() == 2 and below.get_child_count() == 2)

	if debug:
		print("\tCreating vertical corridor...")

	const MIN_TILES_TO_MAKE_DESVIATION: int = 2

	var above_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(above.get_child(0).global_position), corridor_tile_map.local_to_map(above.get_child(1).global_position)]
	var below_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(below.get_child(0).global_position), corridor_tile_map.local_to_map(below.get_child(1).global_position)]

	# var y_start: int = above_tiles[0].y
	var dis: int = below_tiles[0].y - above_tiles[0].y
	var center: int = floor((dis) / 2.0)

	for i in range(1, center):
		#corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * i + Vector2i.LEFT, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * i, ATLAS_ID, FLOOR_TILE_COORDS[0])
		corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN * i, ATLAS_ID, FLOOR_TILE_COORDS[0])
		#corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN * i + Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	for i in range(1, dis - center - MIN_TILES_TO_MAKE_DESVIATION + 1):
		#corridor_tile_map.set_cell(0, below_tiles[0] + Vector2i.UP * i + Vector2i.LEFT, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, below_tiles[0] + Vector2i.UP * i, ATLAS_ID, FLOOR_TILE_COORDS[0])
		corridor_tile_map.set_cell(0, below_tiles[1] + Vector2i.UP * i, ATLAS_ID, FLOOR_TILE_COORDS[0])
		#corridor_tile_map.set_cell(0, below_tiles[1] + Vector2i.UP * i + Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	if above_tiles[0].x > below_tiles[0].x:
		for i in above_tiles[1].x - below_tiles[0].x + 1:
			corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN * center + (i) * Vector2i.LEFT, ATLAS_ID, FLOOR_TILE_COORDS[0])
			corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN + Vector2i.DOWN * center + (i) * Vector2i.LEFT, ATLAS_ID, FLOOR_TILE_COORDS[0])
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	elif above_tiles[0].x < below_tiles[0].x:
		for i in below_tiles[0].x - above_tiles[1].x + 3:
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, ATLAS_ID, FLOOR_TILE_COORDS[0])
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, ATLAS_ID, FLOOR_TILE_COORDS[0])
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	else:
		for i in MIN_TILES_TO_MAKE_DESVIATION:
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, ATLAS_ID, FLOOR_TILE_COORDS[0])
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, ATLAS_ID, FLOOR_TILE_COORDS[0])
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout


## [code]left[/code] is the entry of the room on the left and [code]right[/code] is the entry of the room on the right
func _create_horizontal_corridor(left: Node, right: Node) -> void:
	assert(left.get_child_count() == 2 and right.get_child_count() == 2)

	if debug:
		print("\tCreating horizontal corridor...")

	const MIN_TILES_TO_MAKE_DESVIATION: int = 2

	var left_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(left.get_child(0).global_position), corridor_tile_map.local_to_map(left.get_child(1).global_position)]
	var right_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(right.get_child(0).global_position), corridor_tile_map.local_to_map(right.get_child(1).global_position)]

	# var x_start: int = left_tiles[0].x
	var dis: int = right_tiles[0].x - left_tiles[0].x
	var center: int = floor((dis) / 2.0)

	for i in range(1, center):
		corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT * i, ATLAS_ID, FLOOR_TILE_COORDS[0])
		corridor_tile_map.set_cell(0, left_tiles[1] + Vector2i.RIGHT * i, ATLAS_ID, FLOOR_TILE_COORDS[0])
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	for i in range(1, dis - center - MIN_TILES_TO_MAKE_DESVIATION + 1):
		corridor_tile_map.set_cell(0, right_tiles[0] + Vector2i.LEFT * i, ATLAS_ID, FLOOR_TILE_COORDS[0])
		corridor_tile_map.set_cell(0, right_tiles[1] + Vector2i.LEFT * i, ATLAS_ID, FLOOR_TILE_COORDS[0])
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	if left_tiles[0].y > right_tiles[0].y:
		for i in left_tiles[1].y - right_tiles[0].y + 1:
			corridor_tile_map.set_cell(0, left_tiles[1] + Vector2i.RIGHT * center + (i) * Vector2i.UP, ATLAS_ID, FLOOR_TILE_COORDS[0])
			corridor_tile_map.set_cell(0, left_tiles[1] + Vector2i.RIGHT + Vector2i.RIGHT * center + (i) * Vector2i.UP, ATLAS_ID, FLOOR_TILE_COORDS[0])
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	elif left_tiles[0].y < right_tiles[0].y:
		for i in right_tiles[0].y - left_tiles[1].y + 3:
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, ATLAS_ID, FLOOR_TILE_COORDS[0])
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, ATLAS_ID, FLOOR_TILE_COORDS[0])
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	else:
		for i in MIN_TILES_TO_MAKE_DESVIATION:
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, ATLAS_ID, FLOOR_TILE_COORDS[0])
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, ATLAS_ID, FLOOR_TILE_COORDS[0])
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout


func _create_l_corridor(from: Node, to: Node, from_dir: DungeonRoom.EntryDirection, to_dir: DungeonRoom.EntryDirection) -> void:
	assert(from.get_child_count() == 2 and to.get_child_count() == 2)

	if debug:
		print("\tCreating l corridor...")

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
			corridor_tile_map.set_cell(0, Vector2i(vertical_entry_tiles[0].x, y_coord), ATLAS_ID, FLOOR_TILE_COORDS[0])
			corridor_tile_map.set_cell(0, Vector2i(vertical_entry_tiles[1].x, y_coord), ATLAS_ID, FLOOR_TILE_COORDS[0])
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout

		var x_coord: int = horizontal_entry_tiles[0].x + (-1 if horizontal_dir == DungeonRoom.EntryDirection.LEFT else 1)
		while x_coord != (vertical_entry_tiles[1].x):
			corridor_tile_map.set_cell(0, Vector2i(x_coord, horizontal_entry_tiles[0].y), ATLAS_ID, FLOOR_TILE_COORDS[0])
			corridor_tile_map.set_cell(0, Vector2i(x_coord, horizontal_entry_tiles[1].y), ATLAS_ID, FLOOR_TILE_COORDS[0])
			x_coord += (-1 if horizontal_dir == DungeonRoom.EntryDirection.LEFT else 1)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout


## We have to use this aberration to divide the tilemap because if we don't do it, the lights turn on and off whenever thay please. Because the tilemap is 1 object, it can't have more than 16 lights at the same time, apparently
func _divide_corridor_tile_map() -> void:
	var BLOCK_SIZE: int = 8
	var rect: Rect2 = corridor_tile_map.get_used_rect()
	var x_blocks: int = ceil(rect.size.x / BLOCK_SIZE)
	var y_blocks: int = ceil(rect.size.y / BLOCK_SIZE)

	for i in x_blocks:
		for ii in y_blocks:
			var block_tilemap: TileMap = TileMap.new()
			block_tilemap.add_layer(-1)
			block_tilemap.set_layer_z_index(0, -1)
			block_tilemap.tile_set = corridor_tile_map.tile_set

			for x in range(rect.position.x + i * BLOCK_SIZE, rect.position.x + (i * BLOCK_SIZE) + BLOCK_SIZE):
				for y in range(rect.position.y + ii * BLOCK_SIZE, rect.position.y + (ii * BLOCK_SIZE) + BLOCK_SIZE):
					for layer in corridor_tile_map.get_layers_count():
						block_tilemap.set_cell(layer, Vector2i(x, y), ATLAS_ID, corridor_tile_map.get_cell_atlas_coords(layer, Vector2i(x, y)))

			add_child(block_tilemap)

	corridor_tile_map.queue_free()
	corridor_tile_map = null # At this point this tilemap should not be accessed


func _draw() -> void:
	return
#	if not debug:
#		return

#	if mst_astar == null:
#		for i in delaunay_indices.size() / 3.0:
#			draw_line(room_centers[delaunay_indices[i*3]], room_centers[delaunay_indices[i*3+1]], Color.GREEN, 7)
#			draw_line(room_centers[delaunay_indices[i*3+1]], room_centers[delaunay_indices[i*3+2]], Color.GREEN, 7)
#			draw_line(room_centers[delaunay_indices[i*3+2]], room_centers[delaunay_indices[i*3]], Color.GREEN, 7)
#	else:
	if mst_astar != null:
		for i in mst_astar.get_point_count():
			for j in mst_astar.get_point_connections(i):
				draw_line(room_centers[room_centers.find(mst_astar.get_point_position(i))], room_centers[room_centers.find(mst_astar.get_point_position(j))], Color.YELLOW, 7)

	draw_rect(vertical_corridor_rect, Color.DEEP_SKY_BLUE, true)
	draw_rect(vertical_corridor_1_rect, Color.ORANGE, true)
	draw_rect(vertical_corridor_2_rect, Color.DARK_RED, true)
	draw_rect(horizontal_corridor_rect, Color.YELLOW, true)
	draw_rect(horizontal_corridor_1_rect, Color.BLACK, true)
	draw_rect(horizontal_corridor_2_rect, Color.WHITE, true)
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


class SpawnShape:
	const MARGIN: int = 20


class CircleSpawnShape extends SpawnShape:
	var radius: float

	@warning_ignore("shadowed_variable")
	func _init(radius: float) -> void:
		self.radius = radius


class RectangleSpawnShape extends SpawnShape:
	var size: Vector2

	@warning_ignore("shadowed_variable")
	func _init(size: Vector2) -> void:
		self.size = size
