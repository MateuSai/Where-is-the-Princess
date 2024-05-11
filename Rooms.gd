class_name Rooms extends Node2D

const BIOMES_FOLDER_PATH: String = "res://Rooms/Biomes/"

const TILE_SIZE: int = 16
const MIN_SEPARATION_BETWEEN_ENTRIES: int = TILE_SIZE * 2
static var ATLAS_ID: int

const FLOOR_TILE_COORDS: Array[Vector2i] = [Vector2i(3, 1), Vector2i(5, 2), Vector2i(5, 3), Vector2i(0, 2), Vector2i(0, 3), Vector2i(7, 2), Vector2i(7, 3)]
var CORRIDOR_FLOOR_TILE_COORDS: Array[Vector2i]
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

## This is a variable is initialized on the [method spawn_rooms] function
var spawn_shape: SpawnShape

var rooms: Array[DungeonRoom] = []
var start_room: DungeonRoom
#var end_room: DungeonRoom
var mst_astar: AStar2D = null
var game: Game
# DEBUG
var debug: bool
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

var reload_on_eror: bool

var biome_conf: BiomeConf

var fog_sprite: Sprite2D
var corridor_tile_map: TileMap

func _ready() -> void:
	set_physics_process(false)

	game = get_parent()
	debug = game.debug
	reload_on_eror = game.reload_on_generation_eror
	biome_conf = SavedData.get_biome_conf()
	fog_sprite = $"../FogSprite"
	corridor_tile_map = get_node("CorridorTileMap")

	ATLAS_ID = biome_conf.corridor_atlas_id
	if not biome_conf.corridor_floor_tiles_coor.is_empty():
		CORRIDOR_FLOOR_TILE_COORDS = int_arr_to_vec_array(biome_conf.corridor_floor_tiles_coor)
	else:
		CORRIDOR_FLOOR_TILE_COORDS = FLOOR_TILE_COORDS

	if debug:
		corridor_tile_map.z_index = 1
		var corridor_material: CanvasItemMaterial = CanvasItemMaterial.new()
		corridor_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		corridor_tile_map.material = corridor_material
	else:
		corridor_tile_map.z_index = 0
		corridor_tile_map.material = null

	game.player_added.connect(func() -> void:
		_create_fog()
		if Game.wake_up or Game.came_from_next_level:
			Game.wake_up=false
			Game.came_from_next_level=false
			for room: DungeonRoom in rooms:
				room.remove_enemies_and_open_doors()

		start_room._on_player_entered_room()
	)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and (event as InputEventKey).keycode == KEY_K:
			debug_check_entry_positions = !debug_check_entry_positions
			queue_redraw()

func _physics_process(delta: float) -> void:
	var no_more_rooms_moving: bool = true

	#var dirs: Array[Vector2] = []
	for room: DungeonRoom in rooms:
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
		#var thread: Thread = Thread.new()
		#thread.start(_create_corridors)
		#var ok: bool = thread.wait_to_finish()
		var ok: bool = await _create_corridors()
		if not ok:
			return

func _get_rooms(type: String) -> PackedStringArray:
	var room_paths: PackedStringArray

	var overwrite_room_paths: PackedStringArray = SavedData.get_overwrite_room_paths(type.replace("/", "_").to_lower())
	if overwrite_room_paths.is_empty() or not overwrite_room_paths[0].is_empty():
		room_paths = overwrite_room_paths
	else:
		if type.to_lower().begins_with("end"):
			room_paths = SavedData.get_mod_room_paths(SavedData.run_stats.biome, "end", type.split("/")[1])
		else:
			room_paths = SavedData.get_mod_room_paths(SavedData.run_stats.biome, type)

		var rooms_dir: DirAccess = DirAccess.open(BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/" + type)
		if room_paths.is_empty() and rooms_dir == null:
			print_rich("[color=yellow]Error opening " + BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/" + type + "![/color]")
			return []
		if rooms_dir:
			for file: String in rooms_dir.get_files():
				room_paths.push_back(BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/" + type + "/" + file)

		for i: int in range(room_paths.size() - 1, -1, -1):
			room_paths[i] = room_paths[i].trim_suffix(".remap")
			var room_scene_state: SceneState = (load(room_paths[i]) as PackedScene).get_state()
			for ii: int in room_scene_state.get_node_property_count(0):
				if room_scene_state.get_node_property_name(0, ii) == "levels":
					var levels: String = room_scene_state.get_node_property_value(0, ii)
					if (levels.length() == 1 and levels.is_valid_int() and int(levels) != SavedData.run_stats.level) or (levels.length() >= 3 and levels.find("-") != - 1 and (int(levels.split("-")[0]) > SavedData.run_stats.level or int(levels.split("-")[1]) < SavedData.run_stats.level)):
						room_paths.remove_at(i)
					break

	for ignored_room_path: String in SavedData.get_ignored_rooms():
		if room_paths.has(ignored_room_path):
			room_paths.remove_at(room_paths.find(ignored_room_path))

	return room_paths

func _get_end_rooms() -> Array[PackedStringArray]:
	#var end_rooms_dir: DirAccess = DirAccess.open(BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/End")
	#if end_rooms_dir == null:
		#print("Error opening " + BIOMES_FOLDER_PATH + SavedData.run_stats.biome + "/End!")
		##return []

	var end_rooms: Array[PackedStringArray] = []
	for biome: String in SavedData.get_level_exit_names():
		end_rooms.push_back(_get_rooms("End/" + biome))

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
	#print_debug("spawn_rooms started")

	spawn_shape = SavedData.get_current_level_spawn_shape()

	var start_room_paths: PackedStringArray = _get_rooms("Start")
	var combat_room_paths: PackedStringArray = _get_rooms("Combat")
	var chest_room_paths: PackedStringArray = _get_rooms("Chest")
	var special_room_paths: PackedStringArray = _get_rooms("Special")
	var end_room_paths: Array[PackedStringArray] = _get_end_rooms()

#	room_paths.start.append_array(SavedData.get_mod_room_paths(SavedData.run_stats.biome, "start"))
#	room_paths.combat.append_array(SavedData.get_mod_room_paths(SavedData.run_stats.biome, "combat"))
#	room_paths.special.append_array(SavedData.get_mod_room_paths(SavedData.run_stats.biome, "special"))
#	for end_to in room_paths.end:
#		room_paths.end[end_to].append_array(SavedData.get_mod_room_paths(SavedData.run_stats.biome, "special"))

	# print(room_paths)
	start_room = (load(start_room_paths[randi() % start_room_paths.size()]) as PackedScene).instantiate()
	rooms.push_back(start_room)

	var end_rooms: Array[DungeonRoom] = []
	for array: PackedStringArray in end_room_paths:
		if array.is_empty():
			continue
		var room_scene: PackedScene = load(array[randi() % array.size()])
		var end_room: DungeonRoom = room_scene.instantiate()
		end_rooms.push_back(end_room)
		rooms.push_back(end_room)

	if end_rooms.is_empty():
		print_rich("[color=yellow]No end rooms for this level. Make sure you put the rooms on the correct folder, a subfolder of the 'End' folder[/color]")

	var num_special_rooms: int = SavedData.get_num_rooms("special")
	for i: int in num_special_rooms:
		var random_speacial_room_path: String = special_room_paths[randi() % special_room_paths.size()]
		var random_special_room_scene: PackedScene = load(random_speacial_room_path)
		rooms.push_back(random_special_room_scene.instantiate())
		special_room_paths.remove_at(special_room_paths.find(random_speacial_room_path)) # So the same special room is not spawned 2 times

		if special_room_paths.is_empty() and (i + 1) < num_special_rooms:
			if debug:
				print_rich("[color=yellow]" + str(num_special_rooms) + " special rooms should have spawned, but only " + str(i + 1) + " did, since there are not enough special rooms[/color]")
			break

	var num_chest_rooms: int = SavedData.get_num_rooms("chest")
	for i: int in num_chest_rooms:
		var random_chest_room_path: String = chest_room_paths[randi() % chest_room_paths.size()]
		var random_chest_room_scene: PackedScene = load(random_chest_room_path)
		rooms.push_back(random_chest_room_scene.instantiate())
		chest_room_paths.remove_at(chest_room_paths.find(random_chest_room_path))

		if chest_room_paths.is_empty() and (i + 1) < num_chest_rooms:
			Log.warn(str(num_special_rooms) + " chest rooms should have spawned, but only " + str(i + 1) + " did, since there are not enough chest rooms")
			break

	var num_combat_rooms: int = SavedData.get_num_rooms("combat")
	for i: int in num_combat_rooms:
		#rooms.push_back(INTERMEDIATE_ROOMS[0].instantiate())
		var random_combat_room_path: String = combat_room_paths[randi() % combat_room_paths.size()]
		var combat_room_scene: PackedScene = load(random_combat_room_path)
		rooms.push_back(combat_room_scene.instantiate())

		combat_room_paths.remove_at(combat_room_paths.find(random_combat_room_path))
		if combat_room_paths.is_empty() and (i + 1) < num_combat_rooms:
			if debug:
				print_rich("[color=yellow]" + str(num_combat_rooms) + " combat rooms should have spawned, but only " + str(i + 1) + " did, since there are not enough combat rooms[/color]")
			break

	#print_debug("Adding rooms to scene tree and other things")
	for room: DungeonRoom in rooms:
		Log.debug("Iterating over rooms... Room " + room.name)
		room.name += "_" + str(rooms.find(room))
		room.player_entered.connect(func() -> void:
			Log.debug(room.name + " player_entered. Room id: " + str(room.get_instance_id()))
			#Log.debug(str(room.get_signal_connection_list("player_entered")))
			visited_rooms.push_back(room)
			room_visited.emit(room)
		)
		add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	#print_debug("Finished adding rooms to scene tree and other things")

	#print_debug("Changing rooms start position")
	for room: DungeonRoom in rooms:
		room.float_position = room.get_random_spawn_point(spawn_shape) - room.vector_to_center
		if debug:
			(room.get_node("DebugRoomId") as Label).text = str(rooms.find(room))
	#print_debug("Finished changing rooms start position")

	# return
	set_physics_process(true)

	#print_debug("spawn_rooms finished")

func _create_corridors() -> bool:
	#var room_centers: Array[Vector2] = []
	for i: int in rooms.size():
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
		for i: int in room_centers.size():
			initial_astar.add_point(i, room_centers[i])
		for i: int in delaunay_indices.size() / 3.0:
			i = i * 3
			initial_astar.connect_points(delaunay_indices[i], delaunay_indices[i + 1])
			initial_astar.connect_points(delaunay_indices[i + 1], delaunay_indices[i + 2])
			initial_astar.connect_points(delaunay_indices[i + 2], delaunay_indices[i])
	else:
		# Connect each room with all the others
		for i: int in room_centers.size():
			initial_astar.add_point(i, room_centers[i])
		for i: int in room_centers.size():
			for j: int in room_centers.size():
				if i == j:
					continue
				initial_astar.connect_points(i, j)

	var overwrite_connections: Array[Array] = SavedData.get_overwrite_connections()

	mst_astar = AStar2D.new()
	mst_astar.add_point(mst_astar.get_available_point_id(), room_centers[0])
	initial_astar.set_point_disabled(0)

	if debug:
		print_rich("[b]--- Rooms: creating mst ---[/b]")
		print("initial_astar connections (between indices, not room ids):")
		for i: int in initial_astar.get_point_count():
			print("" + str(i) + ": " + str(initial_astar.get_point_connections(i)))
	# We start with 1 because we already have added the room 0
	for i: int in range(1, initial_astar.get_point_count()):
		var min_connection: Connection = null
		#var min_dist: float = INF  # Minimum distance found so far
		var min_p: Vector2 # Position of that node
		#var p = null  # Current position
		var first_room_id: int = -1
		# Loop through the points in the path
		for id: int in mst_astar.get_point_ids():
			if debug:
				print("Checking room " + str(id) + " neighbours")
			var point: Vector2 = mst_astar.get_point_position(id)
			# Loop through the remaining nodes in the given array
			#print(initial_astar.get_point_count())
			for j: int in initial_astar.get_point_count():
				if initial_astar.is_point_disabled(j):
					if debug:
						print_rich("\t[color=yellow]Point " + str(j) + " is disabled[/color]")
					continue

				var point2: Vector2 = initial_astar.get_point_position(j)
				if debug:
					print_rich("\tChecking room " + str(room_centers.find(point2)) + "")

				if initial_astar.get_point_connections(room_centers.find(point)).has(j):
					var connection: Connection = await _is_connection_possible(id, room_centers.find(point2))
					if connection != null:
						if not overwrite_connections.is_empty():
							var block_connection: bool = true
							for connection_arr: Array in overwrite_connections:
								#var afjsfknasf: int = room_centers.find(point2)
								#var n: int = connection[0]
								#var m: int = connection[1]
								#var p: bool = (n == id and m == afjsfknasf)
								if (connection_arr[0] == id and connection_arr[1] == room_centers.find(point2)) or (connection_arr[0] == room_centers.find(point2) and connection_arr[1] == id):
									block_connection = false
									break
							if block_connection:
								if debug:
									print_rich("\t[color=yellow]Connection between " + str(id) + " and " + str(room_centers.find(point2)) + " is not possible because the connections are overwritten[/color]")
								continue

						if not (min_connection == null or connection.cost < min_connection.cost):
							continue
						#elif connection == null:
							#if debug:
								#print_rich("\t\t[color=yellow]No available connection to " + str(j) + "[/color]")
							#continue

						min_connection = connection
						first_room_id = id
						#min_dist = point.distance_to(point2)
						min_p = point2
						if debug:
							print_rich("\t[color=green]Available connection to " + str(j) + ": " + Connection.Type.keys()[connection.type] + "[/color]")
						#p = point
					else:
						if debug:
							print_rich("\t\t[color=yellow]Rooms " + str(room_centers.find(point)) + " and " + str(room_centers.find(point2)) + " are too close[/color]")
				else:
					if debug:
						print_rich("\t\t[color=yellow]initial_astar does not have any connections between room " + str(room_centers.find(point)) + " and " + str(room_centers.find(point2)) + "[/color]")

		if min_connection == null:
			#assert(false)
			push_error("min_connection is null. There are no more possibles connections but there is some room/rooms that are not connected yet")
			if reload_on_eror:
				game.reload_generation("Could not connect all rooms")
				return false
			continue
		elif min_connection.cost > biome_conf.max_corridor_length:
			if reload_on_eror:
				game.reload_generation("Corridor excedded max_corridor_length defined on the biome configuration")
				return false
			continue

		var n: int = room_centers.find(min_p)
		mst_astar.add_point(n, min_p)
		mst_astar.connect_points(first_room_id, n)

		initial_astar.set_point_disabled(room_centers.find(min_p))
		#if min_connection:
		await _create_corridor_between_rooms(min_connection)
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
		for id: int in initial_astar.get_point_count():
			initial_astar.set_point_disabled(id, false)
		var connections_that_could_be_connected: Array[Connection] = []
		for id: int in initial_astar.get_point_count():
			for id2: int in range(id + 1, initial_astar.get_point_count()):
				# print(str(id) + ": " + str(initial_astar.get_point_connections(id)))
				if initial_astar.get_point_connections(id).has(id2) and not mst_astar.get_point_connections(id).has(id2):
					var found: bool = false
					for connection: Connection in connections_that_could_be_connected:
						if (connection.room_1_id == id and connection.room_2_id == id2) or (connection.room_1_id == id2 and connection.room_2_id == id):
							found = true
							break
					if found:
						continue
					var connection: Connection = await _is_connection_possible(id, id2)
					if connection == null:
						continue
					connection.room_1_id = id
					connection.room_2_id = id2
					connections_that_could_be_connected.push_back(connection)

		connections_that_could_be_connected.sort_custom(func(c: Connection, c2: Connection) -> bool:
			return c.cost < c2.cost
		)

		if debug:
			print("Connections not used after mst:")
			for con: Connection in connections_that_could_be_connected:
				print(con.as_string())
			print("")

		var number_of_extra_connections: int = (round(rooms.size() - 1) * SavedData.get_biome_conf().extra_connections)
		if debug:
			print("Desired number of extra connections: " + str(number_of_extra_connections))
		var i: int = number_of_extra_connections
		while i > 0 and not connections_that_could_be_connected.is_empty():
			var connection: Connection = connections_that_could_be_connected.pop_front()
			if connection.cost > biome_conf.max_corridor_length:
				if biome_conf.restart_generation_if_extra_connections_exceed_max_corridor_length:
					push_error("Generation restarted because extra connection corridor length is too big")
					game.reload_generation("Corridor length exceeded!")
					return false
				else:
					push_error("Skkiping extra connections because their path is too long. Added " + str(i - number_of_extra_connections) + "/" + str(number_of_extra_connections) + " connections")
					break
			#if connection:
			await _create_corridor_between_rooms(connection)
			mst_astar.connect_points(connection.room_1_id, connection.room_2_id)
			i -= 1
			#points_that_could_be_connected.remove_at(rand)
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
	for cell_pos: Vector2i in corridor_tile_map.get_used_cells(0):
		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT) == Vector2i( - 1, -1) and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT * 2) in FLOOR_TILE_COORDS and corridor_tile_map.get_cell_atlas_coords(0, cell_pos) in FLOOR_TILE_COORDS:
			corridor_tile_map.set_cell(0, cell_pos + Vector2i.LEFT, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos) in FLOOR_TILE_COORDS and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN * 2) in FLOOR_TILE_COORDS:
			corridor_tile_map.set_cell(0, cell_pos + Vector2i.DOWN, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout

	# CORRIDOR WALLS
#	corridor_tile_map.set_cells_terrain_connect(0, corridor_tile_map.get_used_cells(0), 0, 0 if ATLAS_ID == 40 else 1)
	for cell_pos: Vector2i in corridor_tile_map.get_used_cells(0):
		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT) == Vector2i( - 1, -1):
			corridor_tile_map.set_cell(1, cell_pos + Vector2i.LEFT, ATLAS_ID, LEFT_WALL_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.RIGHT) == Vector2i( - 1, -1):
			corridor_tile_map.set_cell(1, cell_pos + Vector2i.RIGHT, ATLAS_ID, RIGHT_WALL_COOR)

		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.UP) == Vector2i( - 1, -1):
			corridor_tile_map.erase_cell(1, cell_pos + Vector2i.UP)
			corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, FULL_WALL_COORDS[randi() % FULL_WALL_COORDS.size()])

	var entry_cells: Array[Vector2i] = []
	for room: DungeonRoom in rooms:
		for dir: DungeonRoom.EntryDirection in [DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.DOWN]:
			var entries: Array[EntryPositions] = room.get_entries(dir)
			for entry: EntryPositions in entries:
				var entry_pos: Vector2i = corridor_tile_map.local_to_map(entry.global_position)
				if corridor_tile_map.get_cell_atlas_coords(0, entry_pos + [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN][dir]) in FLOOR_TILE_COORDS:
					room.mark_entry_as_used(entry)
					for pos_node: Marker2D in entry.get_children():
						var cell: Vector2i = corridor_tile_map.local_to_map(pos_node.global_position)
						corridor_tile_map.erase_cell(0, cell)
						corridor_tile_map.erase_cell(1, cell)
						entry_cells.push_back(cell)

	for cell_pos: Vector2i in corridor_tile_map.get_used_cells(0):
		if corridor_tile_map.get_cell_atlas_coords(0, cell_pos) in FULL_WALL_COORDS:
			if corridor_tile_map.get_cell_atlas_coords(1, cell_pos + Vector2i.UP) == RIGHT_WALL_COOR:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_LEFT_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(1, cell_pos + Vector2i.UP) == LEFT_WALL_COOR:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_RIGHT_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.RIGHT) in FLOOR_TILE_COORDS and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i(1, -1)) in FULL_WALL_COORDS:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_RIGHT_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP * 2, ATLAS_ID, UPPER_WALL_LEFT_CORNER_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT) in FLOOR_TILE_COORDS and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i( - 1, -1)) in FULL_WALL_COORDS:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_LEFT_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP * 2, ATLAS_ID, UPPER_WALL_RIGHT_CORNER_COOR)
			else:
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.UP, ATLAS_ID, UPPER_WALL_COOR)

			if corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.RIGHT) == Vector2i( - 1, -1) and not entry_cells.has(cell_pos + Vector2i.RIGHT + Vector2i.DOWN):
				corridor_tile_map.set_cell(1, cell_pos + Vector2i.RIGHT, ATLAS_ID, RIGHT_WALL_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.RIGHT + Vector2i.UP, ATLAS_ID, UPPER_WALL_RIGHT_CORNER_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.LEFT) == Vector2i( - 1, -1) and not entry_cells.has(cell_pos + Vector2i.LEFT + Vector2i.DOWN):
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.LEFT, ATLAS_ID, LEFT_WALL_COOR)
				corridor_tile_map.set_cell(0, cell_pos + Vector2i.LEFT + Vector2i.UP, ATLAS_ID, UPPER_WALL_LEFT_CORNER_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(0, cell_pos) in FLOOR_TILE_COORDS and not corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) in FLOOR_TILE_COORDS:
			if corridor_tile_map.get_cell_atlas_coords(1, cell_pos + Vector2i.DOWN) == RIGHT_WALL_COOR:
				corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, LEFT_BOTTOM_WALL_COOR)
			elif corridor_tile_map.get_cell_atlas_coords(1, cell_pos + Vector2i.DOWN) == LEFT_WALL_COOR:
				corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, RIGHT_BOTTOM_WALL_COOR)
			else:
				corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, BOTTOM_WALL_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(1, cell_pos) == LEFT_WALL_COOR and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) == Vector2i( - 1, -1) and not entry_cells.has(cell_pos + Vector2i.ONE):
			corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, LAST_LEFT_WALL_COOR)
		elif corridor_tile_map.get_cell_atlas_coords(1, cell_pos) == RIGHT_WALL_COOR and corridor_tile_map.get_cell_atlas_coords(0, cell_pos + Vector2i.DOWN) == Vector2i( - 1, -1) and not entry_cells.has(cell_pos + Vector2i.DOWN + Vector2i.LEFT):
			corridor_tile_map.set_cell(1, cell_pos, ATLAS_ID, LAST_RIGHT_WALL_COOR)

		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	for room: DungeonRoom in rooms:
		#FIXME we have to duplicate the room, otherwise the oclidders are messed up
		#var room_path: String = room.scene_file_path
		#var room_substitute: DungeonRoom = load(room_path).instantiate()
		#room_substitute.position = room.position
		#room_substitute.name = room.name
		#rooms.erase(room)
		#room.queue_free()
		#await get_tree().process_frame
		#room = room_substitute
		#rooms.push_back(room)
		#add_child(room)

		room.add_doors_and_walls(corridor_tile_map)
		var weapons_on_floor_paths: Array = biome_conf.levels[SavedData.run_stats.level - 1].overwrite_weapons_on_floor
		if weapons_on_floor_paths.is_empty():
			Log.debug("Not spawning weapons on floor because there aren't specified in the biome configuration file.")
		else:
			room.spawn_weapons_on_floor(weapons_on_floor_paths)
		room.generate_room_white_image()
		room.setup_navigation()

	#start_room = rooms[0]

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	await _add_lights()

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps).timeout

	(%MAP as MiniMap).set_up()
	_divide_corridor_tile_map()

	if debug:
		await get_tree().process_frame
		await get_tree().create_timer(pause_between_steps * 2).timeout

	# FIXME This spaghetti makes the occluders appear on the right position. Without this, it seems like they don't move alongside the rooms, that's why I have to recreate the tilemap after it is on the final position
	for room: DungeonRoom in rooms:
		var tilemap_clone: TileMap = TileMap.new()
		tilemap_clone.y_sort_enabled = true

		for group: String in room.tilemap.get_groups():
			tilemap_clone.add_to_group(group)

		#var tileset: TileSet = TileSet.new()
		#tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
		#var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
		#atlas.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/tilesets/full tilemap forest.png")
		#atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
		#@warning_ignore("integer_division")
		#var width_tiles: int = atlas.texture.get_width()/TILE_SIZE
		#@warning_ignore("integer_division")
		#var height_tiles: int = atlas.texture.get_height()/TILE_SIZE
		#for i: int in width_tiles:
			#for j: int in height_tiles:
				#atlas.create_tile(Vector2i(i, j))
		#tileset.add_source(atlas)

		for layer_i: int in room.tilemap.get_layers_count():
			tilemap_clone.add_layer(layer_i)
			tilemap_clone.set_layer_z_index(layer_i, room.tilemap.get_layer_z_index(layer_i))
			tilemap_clone.set_layer_navigation_enabled(layer_i, room.tilemap.is_layer_navigation_enabled(layer_i))
			tilemap_clone.set_layer_y_sort_enabled(layer_i, room.tilemap.is_layer_y_sort_enabled(layer_i))

		#tileset.add_navigation_layer()
		#tileset.add_navigation_layer()
		tilemap_clone.tile_set = room.tilemap.tile_set

		for layer: int in room.tilemap.get_layers_count():
			for cell: Vector2i in room.tilemap.get_used_cells(layer):
				tilemap_clone.set_cell(layer, cell, room.tilemap.get_cell_source_id(layer, cell), room.tilemap.get_cell_atlas_coords(layer, cell))
		room.tilemap.queue_free()
		room.add_child(tilemap_clone)
		room.tilemap = tilemap_clone

	generation_completed.emit()

	return true

func _add_lights() -> void:
	var TIKI_TORCH_SCENE: PackedScene = load("res://Rooms/Biomes/forest/TikiTorch.tscn")

	for cell: Vector2i in corridor_tile_map.get_used_cells(0):
		if corridor_tile_map.get_cell_atlas_coords(0, cell) == UPPER_WALL_COOR:
			if cell.x % 8 == 0:
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
	for room: DungeonRoom in rooms:
		map_rect = map_rect.merge(room.get_rect())
	map_rect.position -= Vector2.ONE * FOG_PADDING
	map_rect.size += Vector2.ONE * FOG_PADDING * 2
	fog_sprite.position = map_rect.position
	@warning_ignore("narrowing_conversion")
	fog_image = Image.create(map_rect.size.x, map_rect.size.y, false, Image.FORMAT_RGBA8)
	fog_image.fill(Color.BLACK)

	#fog_sprite.texture = ImageTexture.create_from_image(fog_image)

	while is_instance_valid(Globals.player):
		var light: Image = (load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/light_fire.png") as Texture2D).get_image()
		light.convert(Image.FORMAT_RGBA8)
		fog_image.blend_rect(light, Rect2(Vector2.ZERO, light.get_size()), Globals.player.position - map_rect.position - light.get_size() / 2.0)
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

func _create_corridor_between_rooms(connection: Connection) -> void:
	#var dif: Vector2 = room_centers[connection_with] - room_centers[id]
	match connection.type:
		Connection.Type.VERTICAL:
			#var connection: Connection = await _check_entry_positions_vertical_corridor(id if dif.y > 0 else connection_with, connection_with if dif.y > 0 else id, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.UP)
#			var above: Node = rooms[id if dif.y > 0 else connection_with].get_random_entry(DungeonRoom.EntryDirection.DOWN)
#			var below: Node = rooms[connection_with if dif.y > 0 else id].get_random_entry(DungeonRoom.EntryDirection.UP, above)
			await _create_vertical_corridor(connection.room_1_entry_positions, connection.room_2_entry_positions)
#			rooms[id if dif.y > 0 else connection_with].mark_entry_as_used(entries[0])
#			rooms[connection_with if dif.y > 0 else id].mark_entry_as_used(entries[1])
		Connection.Type.HORIZONTAL:
			#var connection: Connection = await _check_entry_positions_horizontal_corridor(id if dif.x > 0 else connection_with, connection_with if dif.x > 0 else id, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.LEFT)
			var left: EntryPositions = connection.room_1_entry_positions if connection.room_1_entry_positions.global_position.x < connection.room_2_entry_positions.global_position.x else connection.room_2_entry_positions
			var right: EntryPositions = connection.room_2_entry_positions if connection.room_1_entry_positions.global_position.x < connection.room_2_entry_positions.global_position.x else connection.room_1_entry_positions
			await _create_horizontal_corridor(left, right)
#			rooms[id if dif.x > 0 else connection_with].mark_entry_as_used(left)
#			rooms[connection_with if dif.x > 0 else id].mark_entry_as_used(right)
		Connection.Type.L_315, Connection.Type.L_45, Connection.Type.L_225, Connection.Type.L_135:
			await _create_l_corridor(connection.room_1_entry_positions, connection.room_2_entry_positions, connection.dir_1, connection.dir_2)
		_:
			assert(false, "Invalid room connection type")
		#Connection.Type.L_315:
			##var directions: Array[Array] = [[DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.UP], [DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.LEFT]]
			##await _decide_direction_and_create_l_corridor(id, connection_with, directions)
			#await _create_l_corridor(connection.room_1_entry_positions, connection.room_2_entry_positions, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.UP)
		#Connection.Type.L_45:
			##var directions: Array[Array] = [[DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.DOWN], [DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.LEFT]]
			##await _decide_direction_and_create_l_corridor(id, connection_with, directions)
			#await _create_l_corridor(connection.room_1_entry_positions, connection.room_2_entry_positions, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.DOWN)
		#Connection.Type.L_225:
			##var directions: Array[Array] = [[DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.UP], [DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.RIGHT]]
			##await _decide_direction_and_create_l_corridor(id, connection_with, directions)
			#await _create_l_corridor(connection.room_1_entry_positions, connection.room_2_entry_positions, DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.UP)
		#Connection.Type.L_135:
			##var directions: Array[Array] = [[DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.DOWN], [DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.RIGHT]]
			##await _decide_direction_and_create_l_corridor(id, connection_with, directions)
			#await _create_l_corridor(connection.room_1_entry_positions, connection.room_2_entry_positions, DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.DOWN)

	connection.room_1_entry_positions.connections += 1
	connection.room_2_entry_positions.connections += 1

## @deprecated
#func _decide_direction_and_create_l_corridor(id: int, connection_with: int, directions: Array[Array]) -> void:
	#var rand: int = randi() % 2
	#var connection: Connection = await _check_entry_positions_l_corridor(id, connection_with, directions[rand][0], directions[rand][1])
	#if connection:
		#await _create_l_corridor(connection.room_1_entry_positions, connection.room_2_entry_positions, directions[rand][0], directions[rand][1])
##		rooms[id].mark_entry_as_used(entries[0])
##		rooms[connection_with].mark_entry_as_used(entries[1])
	#else:
		#rand = (int(rand == 0))
		#connection = await _check_entry_positions_l_corridor(id, connection_with, directions[rand][0], directions[rand][1])
		#assert(connection)
		#await _create_l_corridor(connection.room_1_entry_positions, connection.room_2_entry_positions, directions[rand][0], directions[rand][1])
##		rooms[id].mark_entry_as_used(entries[0])
##		rooms[connection_with].mark_entry_as_used(entries[1])

func _is_connection_possible(id: int, connection_with: int) -> Connection:
	var connection_return: Connection = null

	if debug:
		print("\tChecking connection between " + str(id) + " " + str(connection_with) + "...")
	var dif: Vector2 = room_centers[connection_with] - room_centers[id]
	if abs(dif.x) < TILE_SIZE * 8:
		connection_return = await _check_entry_positions_vertical_corridor(id if dif.y > 0 else connection_with, connection_with if dif.y > 0 else id, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.UP)
		if connection_return:
			if debug:
				print_rich("\t\t[color=green]Vertical connection is possible[/color]")
			#return connection
	elif abs(dif.y) < TILE_SIZE * 8:
		connection_return = await _check_entry_positions_horizontal_corridor(id if dif.x > 0 else connection_with, connection_with if dif.x > 0 else id, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.LEFT)
		if connection_return:
			if debug:
				print_rich("\t\t[color=green]Horizontal connection is possible[/color]")
			#return connection
	else:
		if dif.x > 0 and dif.y > 0:
			connection_return = await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.UP)
			if connection_return:
				if debug:
					print_rich("\t\t[color=green]L connection is possible through if 0[/color]")
				#return connection
			else:
				connection_return = await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.LEFT)
				if debug:
					print_rich("\t\t[color=green]L connection is possible through if 0[/color]")
				#return connection
		elif dif.x > 0 and dif.y < 0:
			connection_return = await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.DOWN)
			if connection_return:
				if debug:
					print_rich("\t\t[color=green]L connection is possible through if 1[/color]")
				#return connection
			else:
				connection_return = await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.LEFT)
				if connection_return:
					if debug:
						print_rich("\t\t[color=green]L connection is possible through if 1[/color]")
					#return connection
		elif dif.x < 0 and dif.y > 0:
			connection_return = await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.UP)
			if connection_return:
				if debug:
					print_rich("\t\t[color=green]L connection is possible through if 2[/color]")
				#return connection
			else:
				connection_return = await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.RIGHT)
				if connection_return:
					if debug:
						print_rich("\t\t[color=green]L connection is possible through if 2[/color]")
					#return connection
		else: # dif.x < 0 and dif.y < 0
			connection_return = await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.DOWN)
			if connection_return:
				if debug:
					print_rich("\t\t[color=green]L connection is possible through if 3[/color]")
				#return connection
			else:
				connection_return = await _check_entry_positions_l_corridor(id, connection_with, DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.RIGHT)
				if connection_return:
					if debug:
						print_rich("\t\t[color=green]L connection is possible through if 3[/color]")
					#return connection

	if not connection_return:
		connection_return = await _check_entry_positions_vertical_corridor(id, connection_with, DungeonRoom.EntryDirection.DOWN, DungeonRoom.EntryDirection.UP)
		if connection_return:
			if debug:
				print_rich("\t\t[color=green]Vertical connection is possible[/color]")
			#return room_connection
		else:
			connection_return = await _check_entry_positions_vertical_corridor(id, connection_with, DungeonRoom.EntryDirection.UP, DungeonRoom.EntryDirection.DOWN)
			if connection_return:
				if debug:
					print_rich("\t\t[color=green]Vertical connection is possible[/color]")
				#return room_connection
			else:
				connection_return = await _check_entry_positions_horizontal_corridor(id, connection_with, DungeonRoom.EntryDirection.RIGHT, DungeonRoom.EntryDirection.LEFT)
				if connection_return:
					if debug:
						print_rich("\t\t[color=green]Horizontal connection is possible[/color]")
					#return room_connection
				else:
					connection_return = await _check_entry_positions_horizontal_corridor(id, connection_with, DungeonRoom.EntryDirection.LEFT, DungeonRoom.EntryDirection.RIGHT)
					if connection_return:
						if debug:
							print_rich("\t\t[color=green]Horizontal connection is possible[/color]")
						#return room_connection

	if connection_return:
		if SavedData.get_limit_entrance_connections_to_one():
			if connection_return.room_1_entry_positions.connections > 0 or connection_return.room_2_entry_positions.connections > 0:
				if debug:
					print_rich("\t[color=yellow]It's not possible to connect the rooms because one of the entrances is already connected and limit_entrance_connections_to_one for the level is true[/color]")
				connection_return = null
	else:
		if debug:
			print_rich("\t[color=yellow]It's not possible to connect the rooms[/color]")

	return connection_return

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

func _check_entry_positions_vertical_corridor(id: int, connection_with: int, id_dir: DungeonRoom.EntryDirection, connection_with_dir: DungeonRoom.EntryDirection) -> Connection:
	for i: int in 2:
		var ids: Array = [[id, connection_with], [connection_with, id]][i]
		var directions: Array = [[id_dir, connection_with_dir], [connection_with_dir, id_dir]][i]
		var entries1: Array[EntryPositions] = rooms[ids[0]].get_entries(directions[0]).duplicate()
		entries1.shuffle()
		var entries2: Array[EntryPositions] = rooms[ids[1]].get_entries(directions[1]).duplicate()
		entries2.shuffle()
		for entry: EntryPositions in entries1:
			for other_entry: EntryPositions in entries2:
				var connection_possible: bool = true
				if entry == null or other_entry == null:
					continue

				var id_entry_position: Vector2 = entry.marker1.global_position
				var connection_with_entry_position: Vector2 = other_entry.marker1.global_position

#				const MIN_TILES_TO_MAKE_DESVIATION: int = 2
				var dis: float = id_entry_position.y - connection_with_entry_position.y
				var center: int = floor((dis) / 2.0)

				# print(dis)
				if abs(dis) < TILE_SIZE * 5 or (directions[0] == DungeonRoom.EntryDirection.UP and id_entry_position.y < connection_with_entry_position.y) or (directions[0] == DungeonRoom.EntryDirection.DOWN and id_entry_position.y > connection_with_entry_position.y):
					continue

				vertical_corridor_1_rect = Rect2(connection_with_entry_position, Vector2(TILE_SIZE * 4, center)).abs()
				vertical_corridor_2_rect = Rect2(id_entry_position, Vector2(TILE_SIZE * 4, -center)).abs()
				#vertical_corridor_2_rect = Rect2(id_entry_position, Vector2(TILE_SIZE * 4, dis - center - MIN_TILES_TO_MAKE_DESVIATION + 1)).abs()
				horizontal_corridor_rect = Rect2(connection_with_entry_position + Vector2.DOWN * center + Vector2.UP * TILE_SIZE * 2, Vector2(id_entry_position.x - connection_with_entry_position.x, TILE_SIZE * 3)).abs()

				for room: DungeonRoom in rooms:
					#if room == rooms[ids[0]] or room == rooms[ids[1]]:
						#continue # Para que no detecta las habitaciones que se conectan, solo las otras

					room_rect = room.get_rect()
					# print("Room " + str(rooms.find(room)) + "  " + str(room_rect))

					if debug_check_entry_positions:
						queue_redraw()
						await get_tree().create_timer(0.6).timeout

					if (room != rooms[ids[1]] and room_rect.intersects(vertical_corridor_1_rect)):
						connection_possible = false
					elif (room != rooms[ids[0]] and room_rect.intersects(vertical_corridor_2_rect)):
						connection_possible = false
					elif room_rect.intersects(horizontal_corridor_rect):
					#if (room_rect.intersects(vertical_corridor_1_rect)) or (room_rect.intersects(vertical_corridor_2_rect)) or room_rect.intersects(horizontal_corridor_rect):
						connection_possible = false

				if connection_possible:
					return Connection.new(entry, other_entry, Connection.Type.VERTICAL, (dis + abs(entry.global_position.x - other_entry.global_position.x)) / TILE_SIZE)

	return null

func _check_entry_positions_horizontal_corridor(id: int, connection_with: int, id_dir: DungeonRoom.EntryDirection, connection_with_dir: DungeonRoom.EntryDirection) -> Connection:
	for i: int in 2:
		var ids: Array = [[id, connection_with], [connection_with, id]][i]
		var directions: Array = [[id_dir, connection_with_dir], [connection_with_dir, id_dir]][i]
		var entries1: Array[EntryPositions] = rooms[ids[0]].get_entries(directions[0]).duplicate()
		entries1.shuffle()
		var entries2: Array[EntryPositions] = rooms[ids[1]].get_entries(directions[1]).duplicate()
		entries2.shuffle()
		for entry: EntryPositions in entries1:
			for other_entry: EntryPositions in entries2:
				var connection_possible: bool = true

				if entry == null or other_entry == null:
					continue

				var id_entry_position: Vector2 = entry.marker1.global_position
				var connection_with_entry_position: Vector2 = other_entry.marker1.global_position

				const MIN_TILES_TO_MAKE_DESVIATION: int = 2
				var dis: float = id_entry_position.x - connection_with_entry_position.x
				var center: int = floor((dis) / 2.0)

				if abs(dis) < TILE_SIZE * 4 or (directions[0] == DungeonRoom.EntryDirection.LEFT and id_entry_position.x < connection_with_entry_position.x) or (directions[0] == DungeonRoom.EntryDirection.RIGHT and id_entry_position.x > connection_with_entry_position.x):
					continue

				horizontal_corridor_1_rect = Rect2(connection_with_entry_position + Vector2.UP * TILE_SIZE * 2, Vector2(center, TILE_SIZE * 4))
				horizontal_corridor_2_rect = Rect2(connection_with_entry_position if connection_with_entry_position.x > id_entry_position.x else id_entry_position, Vector2((dis - center if connection_with_entry_position.x > id_entry_position.x else - dis + center) - (MIN_TILES_TO_MAKE_DESVIATION + 1) * TILE_SIZE, TILE_SIZE * 4))
				vertical_corridor_rect = Rect2((connection_with_entry_position if connection_with_entry_position.x > id_entry_position.x else id_entry_position) + Vector2.LEFT * center, Vector2(TILE_SIZE * 4, (id_entry_position.y - connection_with_entry_position.y) if connection_with_entry_position.x > id_entry_position.x else (connection_with_entry_position.y - id_entry_position.y)))

				for room: DungeonRoom in rooms:
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
					return Connection.new(entry, other_entry, Connection.Type.HORIZONTAL, (dis + abs(entry.global_position.y - other_entry.global_position.y)) / TILE_SIZE)

#	if id == 4 and connection_with == 6:
#		queue_redraw()
#		await get_tree().create_timer(5).timeout

	return null

func _check_entry_positions_l_corridor(id: int, connection_with: int, id_dir: DungeonRoom.EntryDirection, connection_with_dir: DungeonRoom.EntryDirection) -> Connection:
	for i: int in 2:
		var ids: Array = [[id, connection_with], [connection_with, id]][i]
		var directions: Array = [[id_dir, connection_with_dir], [connection_with_dir, id_dir]][i]
		var entries1: Array[EntryPositions] = rooms[ids[0]].get_entries(directions[0]).duplicate()
		entries1.shuffle()
		var entries2: Array[EntryPositions] = rooms[ids[1]].get_entries(directions[1]).duplicate()
		entries2.shuffle()
		for entry: EntryPositions in entries1:
			for other_entry: EntryPositions in entries2:
				var connection_possible: bool = true

				if entry == null or other_entry == null:
					continue

				var id_entry_position: Vector2 = entry.marker1.global_position
				var connection_with_entry_position: Vector2 = other_entry.marker1.global_position

			#	var vertical_corridor_rect: Rect2
			#	var horizontal_corridor_rect: Rect2
				if id_dir == DungeonRoom.EntryDirection.UP or id_dir == DungeonRoom.EntryDirection.DOWN:
					vertical_corridor_rect = Rect2(id_entry_position.x - 32, id_entry_position.y, TILE_SIZE * 4, connection_with_entry_position.y - id_entry_position.y)
					horizontal_corridor_rect = Rect2(connection_with_entry_position.x, connection_with_entry_position.y - 32, id_entry_position.x - connection_with_entry_position.x + TILE_SIZE, TILE_SIZE * 4)
				else:
					vertical_corridor_rect = Rect2(connection_with_entry_position.x - 32, connection_with_entry_position.y, TILE_SIZE * 4, id_entry_position.y - connection_with_entry_position.y)
					horizontal_corridor_rect = Rect2(id_entry_position.x, id_entry_position.y - 32, connection_with_entry_position.x - id_entry_position.x + TILE_SIZE, TILE_SIZE * 4)

				for room: DungeonRoom in rooms:
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
					var type: Connection.Type = Connection.Type.NULL
					var dir_1: DungeonRoom.EntryDirection
					var dir_2: DungeonRoom.EntryDirection
					if (id_dir == DungeonRoom.EntryDirection.RIGHT and connection_with_dir == DungeonRoom.EntryDirection.DOWN):
						type = Connection.Type.L_45
						dir_1 = DungeonRoom.EntryDirection.RIGHT
						dir_2 = DungeonRoom.EntryDirection.DOWN
					elif (id_dir == DungeonRoom.EntryDirection.UP and connection_with_dir == DungeonRoom.EntryDirection.LEFT):
						type = Connection.Type.L_45
						dir_1 = DungeonRoom.EntryDirection.UP
						dir_2 = DungeonRoom.EntryDirection.LEFT
					elif (id_dir == DungeonRoom.EntryDirection.LEFT and connection_with_dir == DungeonRoom.EntryDirection.DOWN):
						type = Connection.Type.L_135
						dir_1 = DungeonRoom.EntryDirection.LEFT
						dir_2 = DungeonRoom.EntryDirection.DOWN
					elif (id_dir == DungeonRoom.EntryDirection.UP and connection_with_dir == DungeonRoom.EntryDirection.RIGHT):
						type = Connection.Type.L_135
						dir_1 = DungeonRoom.EntryDirection.UP
						dir_2 = DungeonRoom.EntryDirection.RIGHT
					elif id_dir == DungeonRoom.EntryDirection.LEFT and connection_with_dir == DungeonRoom.EntryDirection.UP:
						type = Connection.Type.L_225
						dir_1 = DungeonRoom.EntryDirection.LEFT
						dir_2 = DungeonRoom.EntryDirection.UP
					elif id_dir == DungeonRoom.EntryDirection.DOWN and connection_with_dir == DungeonRoom.EntryDirection.RIGHT:
						type = Connection.Type.L_225
						dir_1 = DungeonRoom.EntryDirection.DOWN
						dir_2 = DungeonRoom.EntryDirection.RIGHT
					elif (id_dir == DungeonRoom.EntryDirection.RIGHT and connection_with_dir == DungeonRoom.EntryDirection.UP):
						type = Connection.Type.L_315
						dir_1 = DungeonRoom.EntryDirection.RIGHT
						dir_2 = DungeonRoom.EntryDirection.UP
					elif (id_dir == DungeonRoom.EntryDirection.DOWN and connection_with_dir == DungeonRoom.EntryDirection.LEFT):
						type = Connection.Type.L_315
						dir_1 = DungeonRoom.EntryDirection.DOWN
						dir_2 = DungeonRoom.EntryDirection.LEFT
					assert(type > - 1)
					assert(dir_1 > - 1)
					assert(dir_2 > - 1)
					var connection: Connection = Connection.new(entry, other_entry, type, (abs(entry.global_position.x - other_entry.global_position.x) + abs(entry.global_position.y - other_entry.global_position.y)) / TILE_SIZE)
					connection.dir_1 = dir_1
					connection.dir_2 = dir_2
					return connection

	return null

#region Create corridors
# above and below are entries, with 2 children
func _create_vertical_corridor(above: EntryPositions, below: EntryPositions) -> void:
	assert(above.get_child_count() == 2 and below.get_child_count() == 2)
	if above.global_position.y > below.global_position.y:
		var temp: EntryPositions = above
		above = below
		below = temp
	#var asfasf = above.global_position.y
	#var sdg = below.global_position.y
	assert(above.global_position.y < below.global_position.y)

	if debug:
		print("\tCreating vertical corridor...")

	const MIN_TILES_TO_MAKE_DESVIATION: int = 2

	var above_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(above.marker1.global_position), corridor_tile_map.local_to_map(above.marker2.global_position)]
	var below_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(below.marker1.global_position), corridor_tile_map.local_to_map(below.marker2.global_position)]

	# var y_start: int = above_tiles[0].y
	var dis: int = below_tiles[0].y - above_tiles[0].y
	var center: int = floor((dis) / 2.0)

	for i: int in range(1, center):
		#corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * i + Vector2i.LEFT, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * i, ATLAS_ID, _get_random_corridor_floor_tile_coor())
		corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN * i, ATLAS_ID, _get_random_corridor_floor_tile_coor())
		#corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN * i + Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	for i: int in range(1, dis - center - MIN_TILES_TO_MAKE_DESVIATION + 1):
		#corridor_tile_map.set_cell(0, below_tiles[0] + Vector2i.UP * i + Vector2i.LEFT, 40, FLOOR_TILE_COOR)
		corridor_tile_map.set_cell(0, below_tiles[0] + Vector2i.UP * i, ATLAS_ID, _get_random_corridor_floor_tile_coor())
		corridor_tile_map.set_cell(0, below_tiles[1] + Vector2i.UP * i, ATLAS_ID, _get_random_corridor_floor_tile_coor())
		#corridor_tile_map.set_cell(0, below_tiles[1] + Vector2i.UP * i + Vector2i.RIGHT, 40, FLOOR_TILE_COOR)
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	if above_tiles[0].x > below_tiles[0].x:
		for i: int in above_tiles[1].x - below_tiles[0].x + 1:
			corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN * center + (i) * Vector2i.LEFT, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			corridor_tile_map.set_cell(0, above_tiles[1] + Vector2i.DOWN + Vector2i.DOWN * center + (i) * Vector2i.LEFT, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	elif above_tiles[0].x < below_tiles[0].x:
		for i: int in below_tiles[0].x - above_tiles[1].x + 3:
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	else:
		for i: int in MIN_TILES_TO_MAKE_DESVIATION:
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			corridor_tile_map.set_cell(0, above_tiles[0] + Vector2i.DOWN + Vector2i.DOWN * center + (i) * Vector2i.RIGHT, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout

## [code]left[/code] is the entry of the room on the left and [code]right[/code] is the entry of the room on the right
func _create_horizontal_corridor(left: EntryPositions, right: EntryPositions) -> void:
	assert(left.get_child_count() == 2 and right.get_child_count() == 2)
	assert(left.global_position.x < right.global_position.x)

	if debug:
		print("\tCreating horizontal corridor...")

	const MIN_TILES_TO_MAKE_DESVIATION: int = 2

	var left_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(left.marker1.global_position), corridor_tile_map.local_to_map(left.marker2.global_position)]
	var right_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(right.marker1.global_position), corridor_tile_map.local_to_map(right.marker2.global_position)]

	# var x_start: int = left_tiles[0].x
	var dis: int = right_tiles[0].x - left_tiles[0].x
	var center: int = floor((dis) / 2.0)

	for i: int in range(1, center):
		corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT * i, ATLAS_ID, _get_random_corridor_floor_tile_coor())
		corridor_tile_map.set_cell(0, left_tiles[1] + Vector2i.RIGHT * i, ATLAS_ID, _get_random_corridor_floor_tile_coor())
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	for i: int in range(1, dis - center - MIN_TILES_TO_MAKE_DESVIATION + 1):
		corridor_tile_map.set_cell(0, right_tiles[0] + Vector2i.LEFT * i, ATLAS_ID, _get_random_corridor_floor_tile_coor())
		corridor_tile_map.set_cell(0, right_tiles[1] + Vector2i.LEFT * i, ATLAS_ID, _get_random_corridor_floor_tile_coor())
		if debug:
			await get_tree().create_timer(add_tile_group_time).timeout

	if left_tiles[0].y > right_tiles[0].y:
		for i: int in left_tiles[1].y - right_tiles[0].y + 1:
			corridor_tile_map.set_cell(0, left_tiles[1] + Vector2i.RIGHT * center + (i) * Vector2i.UP, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			corridor_tile_map.set_cell(0, left_tiles[1] + Vector2i.RIGHT + Vector2i.RIGHT * center + (i) * Vector2i.UP, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	elif left_tiles[0].y < right_tiles[0].y:
		for i: int in right_tiles[0].y - left_tiles[1].y + 3:
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
	else:
		for i: int in MIN_TILES_TO_MAKE_DESVIATION:
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			corridor_tile_map.set_cell(0, left_tiles[0] + Vector2i.RIGHT + Vector2i.RIGHT * center + (i) * Vector2i.DOWN, ATLAS_ID, _get_random_corridor_floor_tile_coor())
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout

func _create_l_corridor(from: EntryPositions, to: EntryPositions, from_dir: DungeonRoom.EntryDirection, to_dir: DungeonRoom.EntryDirection) -> void:
	assert(from.get_child_count() == 2 and to.get_child_count() == 2)

	if debug:
		print("\tCreating l corridor...")

	var vertical_entry: EntryPositions
	var horizontal_entry: EntryPositions
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

	var vertical_entry_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(vertical_entry.marker1.global_position), corridor_tile_map.local_to_map(vertical_entry.marker2.global_position)]
	var horizontal_entry_tiles: Array[Vector2i] = [corridor_tile_map.local_to_map(horizontal_entry.marker1.global_position), corridor_tile_map.local_to_map(horizontal_entry.marker2.global_position)]
	# print("fdsfsd" + str(from_tiles[0]) + " " + str(to_tiles[0]))

	if vertical_dir == DungeonRoom.EntryDirection.UP or vertical_dir == DungeonRoom.EntryDirection.DOWN:
		var y_coord: int = vertical_entry_tiles[0].y
		while y_coord != (horizontal_entry_tiles[0].y if vertical_dir == DungeonRoom.EntryDirection.UP else horizontal_entry_tiles[1].y):
			y_coord += (-1 if vertical_dir == DungeonRoom.EntryDirection.UP else 1)
			corridor_tile_map.set_cell(0, Vector2i(vertical_entry_tiles[0].x, y_coord), ATLAS_ID, _get_random_corridor_floor_tile_coor())
			corridor_tile_map.set_cell(0, Vector2i(vertical_entry_tiles[1].x, y_coord), ATLAS_ID, _get_random_corridor_floor_tile_coor())
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout

		var x_coord: int = horizontal_entry_tiles[0].x + (-1 if horizontal_dir == DungeonRoom.EntryDirection.LEFT else 1)
		while x_coord != (vertical_entry_tiles[1].x):
			corridor_tile_map.set_cell(0, Vector2i(x_coord, horizontal_entry_tiles[0].y), ATLAS_ID, _get_random_corridor_floor_tile_coor())
			corridor_tile_map.set_cell(0, Vector2i(x_coord, horizontal_entry_tiles[1].y), ATLAS_ID, _get_random_corridor_floor_tile_coor())
			x_coord += (-1 if horizontal_dir == DungeonRoom.EntryDirection.LEFT else 1)
			if debug:
				await get_tree().create_timer(add_tile_group_time).timeout
#endregion

## We have to use this aberration to divide the tilemap because if we don't do it, the lights turn on and off whenever thay please. Because the tilemap is 1 object, it can't have more than 16 lights at the same time, apparently
func _divide_corridor_tile_map() -> void:
	var BLOCK_SIZE: int = 8
	var rect: Rect2 = corridor_tile_map.get_used_rect()
	var x_blocks: int = ceil(rect.size.x / BLOCK_SIZE)
	var y_blocks: int = ceil(rect.size.y / BLOCK_SIZE)

	for i: int in x_blocks:
		for ii: int in y_blocks:
			var block_tilemap: TileMap = TileMap.new()
			block_tilemap.add_layer( - 1)
			block_tilemap.set_layer_z_index(0, corridor_tile_map.get_layer_z_index(0))
			block_tilemap.set_layer_z_index(1, corridor_tile_map.get_layer_z_index(1))
			block_tilemap.set_layer_navigation_enabled(0, corridor_tile_map.is_layer_navigation_enabled(0))
			block_tilemap.tile_set = corridor_tile_map.tile_set

			for x: int in range(rect.position.x + i * BLOCK_SIZE, rect.position.x + (i * BLOCK_SIZE) + BLOCK_SIZE):
				for y: int in range(rect.position.y + ii * BLOCK_SIZE, rect.position.y + (ii * BLOCK_SIZE) + BLOCK_SIZE):
					for layer: int in corridor_tile_map.get_layers_count():
						block_tilemap.set_cell(layer, Vector2i(x, y), ATLAS_ID, corridor_tile_map.get_cell_atlas_coords(layer, Vector2i(x, y)))

			add_child(block_tilemap)

	corridor_tile_map.queue_free()
	corridor_tile_map = null # At this point this tilemap should not be accessed

func _get_random_corridor_floor_tile_coor() -> Vector2i:
	return CORRIDOR_FLOOR_TILE_COORDS[randi() % CORRIDOR_FLOOR_TILE_COORDS.size()]

func int_arr_to_vec_array(array: Array[Array]) -> Array[Vector2i]:
	var vec_arr: Array[Vector2i] = []
	#var tmp_arr: Array = []

	for arr: Array[int] in array:
		# For some reason, if I define a type for the variables, coor is always (0, 0). DO NOT PUT A TYPE
		var a = arr[0]
		var b = arr[1]
		var coor: Vector2i = Vector2i(a, b)
		vec_arr.push_back(coor)

	#vec_arr.assign(tmp_arr)
	return vec_arr

func _draw() -> void:
#	if not debug:
#		return

#	if mst_astar != null:
#		for i in mst_astar.get_point_count():
#			for j in mst_astar.get_point_connections(i):
#				draw_line(room_centers[room_centers.find(mst_astar.get_point_position(i))], room_centers[room_centers.find(mst_astar.get_point_position(j))], Color.YELLOW, 7)

	if debug_check_entry_positions:
		draw_rect(vertical_corridor_rect, Color.DEEP_SKY_BLUE, true)
		draw_rect(vertical_corridor_1_rect, Color.ORANGE, true)
		draw_rect(vertical_corridor_2_rect, Color.GREEN, true)
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

class Connection:
	var room_1_id: int = -1
	var room_2_id: int = -1

	var dir_1: DungeonRoom.EntryDirection = DungeonRoom.EntryDirection.NULL
	var dir_2: DungeonRoom.EntryDirection = DungeonRoom.EntryDirection.NULL

	var room_1_entry_positions: EntryPositions
	var room_2_entry_positions: EntryPositions
	enum Type {
		NULL = -1,
		VERTICAL,
		HORIZONTAL,
		L_315,
		L_45,
		L_225,
		L_135,
	}
	var type: Type
	var cost: int

	@warning_ignore("shadowed_variable")
	func _init(room_1_entry_positions: EntryPositions, room_2_entry_positions: EntryPositions, type: Type, cost: int) -> void:
		self.room_1_entry_positions = room_1_entry_positions
		self.room_2_entry_positions = room_2_entry_positions
		self.type = type
		self.cost = cost

	func as_string() -> String:
		return "room_1_id: " + str(room_1_id) + ", room_2_id: " + str(room_2_id) + ", cost: " + str(cost)
