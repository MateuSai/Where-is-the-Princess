class_name DungeonRoom extends NavigationRegion2D

## If empty, the room will appear on all the levels of the biome. If it has a number, the room will appear on the specified level. If it has a range, it will appear on all the levels inclusive. For example, [code]1-3[/code] will make the room appear on the levels 1, 2, and 3 of his biome.
## [br][br]
## If the value is invalid, an error will appear and the room will not be used
@export var levels: String = ""

const GROUND_UNITS_NAVIGATION_GROUP: StringName = "navigation_polygon_source_group"
const FLYING_UNITS_NAVIGATION_GROUP: StringName = "flying_units_navigation_polygon_source_group"

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

const HORIZONTAL_UP_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/HorizontalUpDoor.tscn")
const HORIZONTAL_DOWN_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/HorizontalDownDoor.tscn")
const VERTICAL_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/VerticalDoor.tscn")

const WATER_LAYER_ID: int = 4
var ATLAS_ID: int

var num_enemies: int

var float_position: Vector2

enum EntryDirection {
	LEFT,
	UP,
	RIGHT,
	DOWN,
}
var used_entries: Array[Node] = []

var agent_radius: int = 3
var navigation_map_flying_units: RID
var navigation_region_flying_units: RID
signal navigation_updated()

signal player_entered()
signal closed()
signal cleared()
signal last_enemy_died(enemy: Enemy)

@onready var rooms: Rooms = get_parent()

@onready var disable_horizontal_separation_steering: bool = SavedData.get_disable_horizontal_separation_steering()

@onready var tilemap: TileMap = get_node("TileMap")
@onready var flying_units_navigation_tilemap: TileMap = $FlyingUnitsNavigationTileMap
@onready var black_tilemap: TileMap = get_node("BlackTileMap")
@onready var teleport_position: Marker2D = $TeleportPosition

@onready var tilemap_offset: Vector2i = tilemap.get_used_rect().position * Rooms.TILE_SIZE
var room_white_image: Image
@onready var room_white_image_offset: Vector2i = tilemap_offset

@onready var vector_to_center: Vector2 = ((tilemap.get_used_rect().size/2) + tilemap.get_used_rect().position) * Rooms.TILE_SIZE
@onready var radius: float = (tilemap.get_used_rect().size.length() * Rooms.TILE_SIZE) / 2.0
const RECT_MARGIN: int = 64
@onready var room_rect: Rect2 = Rect2(tilemap.get_used_rect().position * Rooms.TILE_SIZE, tilemap.get_used_rect().size * Rooms.TILE_SIZE).grow(RECT_MARGIN)
@onready var entries: Array[Node2D] = [get_node("Entries/Left"), get_node("Entries/Up"), get_node("Entries/Right"), get_node("Entries/Down")]
@onready var door_container: Node2D = get_node("Doors")
@onready var enemy_positions_container: Node2D = get_node("EnemyPositions")
@onready var items_container: Node2D = $Items


func _ready() -> void:
	assert(tilemap.position == Vector2.ZERO, "The tilemap must be at the position (0, 0)")
	assert(entries[0].get_child_count() or entries[1].get_child_count() or entries[2].get_child_count() or entries[3].get_child_count(), "What are you doing!? How I'm supposed to access the room? Put at least one entry.")

#	print(name + ": " + str(tilemap.get_used_rect()))

	num_enemies = enemy_positions_container.get_child_count()

	ATLAS_ID = SavedData.get_biome_conf().room_atlas_id

	black_tilemap.modulate = ProjectSettings.get("rendering/environment/defaults/default_clear_color")
	for cell_pos: Vector2i in tilemap.get_used_cells(0):
		black_tilemap.set_cell(0, cell_pos, 0, Vector2i(0, 0))
	for cell_pos: Vector2i in tilemap.get_used_cells(1):
		black_tilemap.set_cell(0, cell_pos, 0, Vector2i(0, 0))

	if rooms.game.debug:
		black_tilemap.hide()

	flying_units_navigation_tilemap.hide()


func _exit_tree() -> void:
	_free_navigation()


func _draw() -> void:
	pass
#	if get_parent().get_parent().debug:
#		draw_rect(room_rect, Color.RED)
#		draw_circle(vector_to_center, radius, Color.RED)
#		draw_circle(vector_to_center, (vector_to_center - Vector2(tilemap.get_used_rect().position * Rooms.TILE_SIZE)).length(), Color.RED)


func generate_room_white_image() -> void:
	var size: Vector2 = tilemap.get_used_rect().size * Rooms.TILE_SIZE

	var tile_cells: Array = tilemap.get_used_cells(0)
#	tile_cells.append_array(tilemap.get_used_cells(WATER_LAYER_ID))
	#tile_cells.append_array(tilemap.get_used_cells(1))

	# We add one more tile in the direction of the entries so the entries of the room are more visible
	var increased_left_size: bool = false
	var increased_right_size: bool = false
	var increased_up_size: bool = false
	var increased_down_size: bool = false
	for dir: EntryDirection in [EntryDirection.LEFT, EntryDirection.UP, EntryDirection.RIGHT, EntryDirection.DOWN]:
		for entry: Node2D in entries[dir].get_children():
			if entry in used_entries:
				tile_cells.push_back(tilemap.local_to_map(entry.position) + [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN][dir])
				if dir in [EntryDirection.LEFT, EntryDirection.RIGHT]:
					tile_cells.push_back(tilemap.local_to_map(entry.position) + [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN][dir] + Vector2i.UP)
					tile_cells.push_back(tilemap.local_to_map(entry.position) + [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN][dir] + Vector2i.DOWN)
					if dir == EntryDirection.LEFT and not increased_left_size:
						increased_left_size = true
						room_white_image_offset.x -= Rooms.TILE_SIZE
						size.x += Rooms.TILE_SIZE
					elif dir == EntryDirection.RIGHT and not increased_right_size:
						increased_right_size = true
						size.x += Rooms.TILE_SIZE
				else: # UP, DOWN
#					tile_cells.push_back(tilemap.local_to_map(entry.position) + [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN][dir] + Vector2i.LEFT)
					tile_cells.push_back(tilemap.local_to_map(entry.position) + [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN][dir] + Vector2i.RIGHT)
#					tile_cells.push_back(tilemap.local_to_map(entry.position) + [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN][dir] + Vector2i.RIGHT * 2)
					if dir == EntryDirection.UP and not increased_up_size:
						increased_up_size = true
						room_white_image_offset.y -= Rooms.TILE_SIZE
						size.y += Rooms.TILE_SIZE
					elif dir == EntryDirection.DOWN and not increased_down_size:
						increased_down_size = true
						size.y += Rooms.TILE_SIZE

	@warning_ignore("narrowing_conversion")
	room_white_image = Image.create(size.x, size.y, false, Image.FORMAT_RGBAH)

	for tile_cell: Vector2i in tile_cells:
		if (tilemap.get_cell_atlas_coords(0, tile_cell) in [Rooms.UPPER_WALL_COOR, Rooms.UPPER_WALL_LEFT_COOR, Rooms.UPPER_WALL_LEFT_CORNER_COOR, Rooms.UPPER_WALL_RIGHT_COOR, Rooms.UPPER_WALL_RIGHT_CORNER_COOR, Rooms.LEFT_WALL_COOR, Rooms.RIGHT_WALL_COOR, Rooms.LAST_LEFT_WALL_COOR, Rooms.LAST_RIGHT_WALL_COOR]): # if the atlas coordinates are (-1, -1), it means it's a corridor tile
			continue

		var rect: Rect2 = Rect2(Vector2(tile_cell * Rooms.TILE_SIZE - room_white_image_offset), Vector2.ONE * Rooms.TILE_SIZE)
		@warning_ignore("narrowing_conversion")
		var image: Image = Image.create(rect.size.x, rect.size.y, false, Image.FORMAT_RGBAH)
		image.fill(Color.WHITE)
		#var light: Image = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/light_fire.png").get_image()
		#light.convert(Image.FORMAT_RGBAH)
		var image_size: Vector2 = image.get_size()
		room_white_image.blend_rect(image, Rect2(Vector2.ZERO, image_size), rect.position)


func get_separation_steering_dir(rooms_array: Array[DungeonRoom], delta: float) -> Vector2:
	var dir: Vector2 = Vector2.ZERO
	var this_room_rect: Rect2 = room_rect
	this_room_rect.position += position
	for room: DungeonRoom in rooms_array:
		if room == self:
			continue
		var vector_to_room: Vector2 = (room.position + room.vector_to_center) - (position + vector_to_center)
		var other_room_rect: Rect2 = room.room_rect
		other_room_rect.position += room.position
		if this_room_rect.intersects(other_room_rect):
#		if vector_to_room.length() < (radius + room.radius):
			# vector_to_room is a vector to the other room, but we don't want to move in that direction, bhut in the other. We will only add the direction if the room areas are colliding. If they are colliding just at the limit (vector_to_room.length() - radius - room.radius) will be 0, so that room won't affect this room movement. As the rooms glow closer (vector_to_room.length() - radius - room.radius) will increase negatively, so if the rooms are on the same position it will be equal to vector_to_room.length(). The fact that this value is negative makes the rooms separate instead of coming closer
			#dir += vector_to_room * (vector_to_room.length() - radius - room.radius)
			dir += -vector_to_room# * (vector_to_room.length() - radius - room.radius)
			#dir -= 1 - (vector_to_room)

	if disable_horizontal_separation_steering:
		dir.x = 0

	float_position += dir.normalized() * 500 * randf_range(0.9, 1.1) * delta
	#float_position += dir * randf_range(0.9, 1.1) * delta
	position = round(float_position/Rooms.TILE_SIZE) * Rooms.TILE_SIZE

	return dir


func setup_navigation() -> void:
	navigation_polygon.agent_radius = agent_radius
	navigation_polygon.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_EXPLICIT

	update_navigation()


func update_navigation() -> void:
	bake_navigation_polygon(false)
	NavigationServer2D.region_set_transform(get_region_rid(), get_global_transform())

	_free_navigation()
	_generate_flying_units_navigation()
	NavigationServer2D.region_set_transform(navigation_region_flying_units, get_global_transform())
	#set_navigation_map(navigation_map_flying_units)
	#bake_navigation_polygon(false)

	navigation_updated.emit()


func _has_entry(dir: EntryDirection) -> bool:
	var direction_entries: Array[Node] = entries[dir].get_children()
#	for entry in used_entries:
#		if direction_entries.has(entry):
#			direction_entries.erase(entry)

	return direction_entries.size() > 0


#func get_entry_position(dir: EntryDirection) -> Vector2:
#	return entries[dir].get_children()[0].global_position


func get_entries(dir: EntryDirection) -> Array[EntryPositions]:
	var arr: Array[EntryPositions] = []
	arr.assign(entries[dir].get_children())
	return arr


func get_random_entry(dir: EntryDirection, to_connect_to: Node2D = null) -> Node:
	var direction_entries: Array[EntryPositions] = get_entries(dir)
#	for entry in used_entries:
#		if direction_entries.has(entry):
#			direction_entries.erase(entry)

#	if direction_entries.is_empty():
#		return null
#	else:
	var usable_entries: Array[EntryPositions] = direction_entries.duplicate()

	if to_connect_to != null:
		usable_entries = usable_entries.filter(func(entry: EntryPositions) -> void:
			return is_connection_between_entries_possible(entry, dir, to_connect_to)
#			match dir:
#				EntryDirection.LEFT:
#					return to_connect_to.global_position.x < entry.global_position.x - Rooms.TILE_SIZE
#				EntryDirection.UP:
#					return to_connect_to.global_position.y < entry.global_position.y - Rooms.TILE_SIZE
#				EntryDirection.RIGHT:
#					return to_connect_to.global_position.x > entry.global_position.x + Rooms.TILE_SIZE
#				EntryDirection.DOWN:
#					return to_connect_to.global_position.y > entry.global_position.y + Rooms.TILE_SIZE
		)

	if usable_entries.is_empty():
		return null

	var rand_entry: Node = usable_entries[randi() % usable_entries.size()]
	#used_entries.push_back(rand_entry)
	return rand_entry


func is_connection_between_entries_possible(this_room_entry: Node2D, this_room_entry_dir: EntryDirection, other_room_entry: Node2D) -> bool:
	match this_room_entry_dir:
		EntryDirection.LEFT:
			return other_room_entry.global_position.x < this_room_entry.global_position.x - Rooms.MIN_SEPARATION_BETWEEN_ENTRIES
		EntryDirection.UP:
			return other_room_entry.global_position.y < this_room_entry.global_position.y - Rooms.MIN_SEPARATION_BETWEEN_ENTRIES
		EntryDirection.RIGHT:
			return other_room_entry.global_position.x > this_room_entry.global_position.x + Rooms.MIN_SEPARATION_BETWEEN_ENTRIES
		EntryDirection.DOWN:
			return other_room_entry.global_position.y > this_room_entry.global_position.y + Rooms.MIN_SEPARATION_BETWEEN_ENTRIES

	return false


func mark_entry_as_used(entry: Node) -> void:
	if not used_entries.has(entry):
		used_entries.push_back(entry)


func add_doors_and_walls(corridor_tilemap: TileMap) -> void:
	for dir: EntryDirection in [EntryDirection.LEFT, EntryDirection.RIGHT]:
		for entry: Node2D in entries[dir].get_children():
			if entry in used_entries:
				black_tilemap.erase_cell(0, black_tilemap.local_to_map(entry.position) + Vector2i.UP * 2)
				black_tilemap.erase_cell(0, black_tilemap.local_to_map(entry.position) + Vector2i.UP)
				black_tilemap.erase_cell(0, black_tilemap.local_to_map(entry.position))
				black_tilemap.erase_cell(0, black_tilemap.local_to_map(entry.position) + Vector2i.DOWN)

				var vertical_door: Door = VERTICAL_DOOR.instantiate()
				vertical_door.position = floor(entry.position / 16) * 16
				if dir == EntryDirection.LEFT:
					vertical_door.position += Vector2(18, 6)
				else:
					vertical_door.position += Vector2(-2, 4)
					vertical_door.scale.x = -1
				door_container.add_child(vertical_door)
			else:
				var tile_positions: Array[Vector2i] = []
				tile_positions.push_back(tilemap.local_to_map(entry.position + (entry.get_child(0) as Marker2D).position))
				tile_positions.push_back(tilemap.local_to_map(entry.position + (entry.get_child(1) as Marker2D).position))
				tilemap.erase_cell(3, tile_positions[1])
				tilemap.erase_cell(0, tile_positions[0] + Vector2i.UP * 2)
				tilemap.erase_cell(0, tile_positions[0] + Vector2i.UP)
				tilemap.erase_cell(0, tile_positions[0])
				tilemap.erase_cell(0, tile_positions[1])
				if dir == EntryDirection.LEFT:
					if tilemap.get_cell_atlas_coords(0, tile_positions[0] + Vector2i.UP * 2 + Vector2i.RIGHT) == Rooms.UPPER_WALL_COOR:
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, ATLAS_ID, Rooms.UPPER_WALL_LEFT_CORNER_COOR)
					else:
						tilemap.set_cell(1, tile_positions[0] + Vector2i.UP * 2, ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(1, tile_positions[0] + Vector2i.UP, ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(1, tile_positions[0], ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(1, tile_positions[1], ATLAS_ID, Rooms.LEFT_WALL_COOR)
				else:
					if tilemap.get_cell_atlas_coords(0, tile_positions[0] + Vector2i.UP * 2 + Vector2i.LEFT) == Rooms.UPPER_WALL_COOR:
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, ATLAS_ID, Rooms.UPPER_WALL_RIGHT_CORNER_COOR)
					else:
						tilemap.set_cell(1, tile_positions[0] + Vector2i.UP * 2, ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(1, tile_positions[0] + Vector2i.UP, ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(1, tile_positions[0], ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(1, tile_positions[1], ATLAS_ID, Rooms.RIGHT_WALL_COOR)
	for dir: EntryDirection in [EntryDirection.UP, EntryDirection.DOWN]:
		for entry: Node2D in entries[dir].get_children():
			if entry in used_entries:
				black_tilemap.erase_cell(0, black_tilemap.local_to_map(entry.position))
				black_tilemap.erase_cell(0, black_tilemap.local_to_map(entry.position) + Vector2i.RIGHT)

				var horizontal_door: Door = HORIZONTAL_UP_DOOR.instantiate() if dir == EntryDirection.UP else HORIZONTAL_DOWN_DOOR.instantiate()
				horizontal_door.position = floor(entry.position / 16) * 16 + Vector2(Rooms.TILE_SIZE, Rooms.TILE_SIZE + 12)
				door_container.add_child(horizontal_door)
				if dir == EntryDirection.UP:
					corridor_tilemap.erase_cell(1, corridor_tilemap.local_to_map(entry.global_position) + Vector2i.UP)
					corridor_tilemap.erase_cell(1, corridor_tilemap.local_to_map(entry.global_position) + Vector2i.UP + Vector2i.RIGHT)
			else:
				var tile_positions: Array[Vector2i] = []
				tile_positions.push_back(tilemap.local_to_map(entry.position + (entry.get_child(0) as Marker2D).position))
				tile_positions.push_back(tilemap.local_to_map(entry.position + (entry.get_child(1) as Marker2D).position))
				if dir == EntryDirection.UP:
					tilemap.set_cell(0, tile_positions[0] + Vector2i.LEFT, ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0], ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1], ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1] + Vector2i.RIGHT, ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0] + Vector2i.DOWN, ATLAS_ID, Rooms.FULL_WALL_COORDS[randi() % Rooms.FULL_WALL_COORDS.size()])
					tilemap.set_cell(0, tile_positions[1] + Vector2i.DOWN, ATLAS_ID, Rooms.FULL_WALL_COORDS[randi() % Rooms.FULL_WALL_COORDS.size()])
				else:
					tilemap.set_cell(1, tile_positions[0] + Vector2i.LEFT, ATLAS_ID, Rooms.BOTTOM_WALL_COOR)
					tilemap.set_cell(1, tile_positions[0], ATLAS_ID, Rooms.BOTTOM_WALL_COOR)
					tilemap.set_cell(1, tile_positions[1], ATLAS_ID, Rooms.BOTTOM_WALL_COOR)
					tilemap.set_cell(1, tile_positions[1] + Vector2i.RIGHT, ATLAS_ID, Rooms.BOTTOM_WALL_COOR)

	for door: Door in door_container.get_children():
		door.player_entered_room.connect(_on_player_entered_room)


func _on_enemy_killed(enemy: Enemy) -> void:
	num_enemies -= 1
	if num_enemies == 0:
		last_enemy_died.emit(enemy)
		await get_tree().process_frame
		cleared.emit()
		Globals.room_cleared.emit()
		_open_doors()


func _open_doors() -> void:
	for door: Door in door_container.get_children():
		door.open()


func _close_entrance() -> void:
	for door: Door in door_container.get_children():
		door.close()
#	for entry_position in entrance.get_children():
#		tilemap.set_cell(1, tilemap.local_to_map(entry_position.position), 1, Vector2i.ZERO)
#		tilemap.set_cell(1, tilemap.local_to_map(entry_position.position) + Vector2i.DOWN, 2, Vector2i.ZERO)


func _spawn_enemies() -> void:
	var enemy_paths: Array[String] = Globals.get_enemy_paths(SavedData.run_stats.biome)

	for enemy_marker: EnemyMarker in enemy_positions_container.get_children():
		var enemy: CharacterBody2D
		if enemy_marker.enemy_name.is_empty():
			var enemy_scene: PackedScene = load(enemy_paths[randi() % enemy_paths.size()])
			enemy = enemy_scene.instantiate()
		else:
			var enemy_scene: PackedScene = load(Globals.ENEMIES[enemy_marker.enemy_name].path as String)
			enemy = enemy_scene.instantiate()
		enemy.position = enemy_marker.position
		call_deferred("add_child", enemy)

		var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
		spawn_explosion.position = enemy_marker.position
		call_deferred("add_child", spawn_explosion)



func _on_player_entered_room() -> void:
	player_entered.emit()

	rooms.clear_room_fog(position + Vector2(room_white_image_offset), room_white_image)

	for door: Door in door_container.get_children():
		door.player_entered_room.disconnect(_on_player_entered_room)

	if num_enemies > 0:
		_close_entrance()
		_spawn_enemies()
		closed.emit()
		Globals.room_closed.emit()

		var tween: Tween = create_tween()
		tween.tween_property(black_tilemap, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tween.finished
		black_tilemap.queue_free()
	else:
		black_tilemap.queue_free()
		#_close_entrance()
		#_open_doors()


func get_random_spawn_point(spawn_shape: Rooms.SpawnShape) -> Vector2:
	#if name.begins_with("Boss"):
		#pass

	var directions_with_entry: Array[EntryDirection] = []
	for dir: EntryDirection in [EntryDirection.LEFT, EntryDirection.UP, EntryDirection.RIGHT, EntryDirection.DOWN]:
		if _has_entry(dir):
			directions_with_entry.push_back(dir)

	var entries_dir: Vector2 = Vector2.ZERO
	for dir: EntryDirection in directions_with_entry:
		entries_dir += [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN][dir]
	entries_dir *= -1

	if directions_with_entry.size() == 4 or entries_dir == Vector2.ZERO:
		if spawn_shape is Rooms.CircleSpawnShape:
			var circle_spawn_shape: Rooms.CircleSpawnShape = spawn_shape
			return Vector2.RIGHT.rotated(randf_range(0, 2 * PI)) * randf_range(0, circle_spawn_shape.radius - circle_spawn_shape.MARGIN)
		else: # Rectangle
			var rectangle_spawn_shape: Rooms.RectangleSpawnShape = spawn_shape
			return Vector2(randf_range(rectangle_spawn_shape.MARGIN, rectangle_spawn_shape.size.x - rectangle_spawn_shape.MARGIN), randf_range(rectangle_spawn_shape.MARGIN, rectangle_spawn_shape.size.y - rectangle_spawn_shape.MARGIN))
	else:
		#print(name + " " + str(en tries_dir) + " " + str(directions_with_entry))
		if spawn_shape is Rooms.CircleSpawnShape:
			var circle_spawn_shape: Rooms.CircleSpawnShape = spawn_shape
			return Vector2.RIGHT.rotated(randf_range(entries_dir.angle() - PI/8, entries_dir.angle() + PI/8)) * circle_spawn_shape.radius
		else: # Rectangle
			var rectangle_spawn_shape: Rooms.RectangleSpawnShape = spawn_shape
			entries_dir = ((entries_dir + Vector2.ONE) / 2.0).normalized()
#			entries_dir.x = clamp(entries_dir.x, 0, 1)
#			entries_dir.y = clamp(entries_dir.y, 0, 1)
			return rectangle_spawn_shape.size * entries_dir


func get_rect() -> Rect2i:
#	return Rect2i(tilemap.get_used_rect().position * Rooms.TILE_SIZE, tilemap.get_used_rect().size * Rooms.TILE_SIZE)
	return Rect2(Vector2i(position) + (tilemap.get_used_rect().position * 16), (tilemap.get_used_rect().size * 16))


## Increase num_enemies by 1 and adds the enemy to the scene tree
func add_enemy(enemy: Enemy) -> void:
	num_enemies += 1
	add_child(enemy)


func add_item_on_floor(item_on_floor: ItemOnFloor, at_pos: Vector2) -> void:
	item_on_floor.position = at_pos
	items_container.add_child(item_on_floor)


func get_items() -> Array[ItemOnFloor]:
	var array: Array[ItemOnFloor] = []
	array.assign(items_container.get_children())
	return array


func _generate_flying_units_navigation() -> void:
	# Create a navigation mesh resource.
	var navigation_mesh_flying_units: NavigationPolygon = NavigationPolygon.new()
	navigation_mesh_flying_units.source_geometry_group_name = "flying_units_navigation_polygon_source_group"
	navigation_mesh_flying_units.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_EXPLICIT
	# Set appropriated parameters for the size of your agents.
	navigation_mesh_flying_units.agent_radius = navigation_polygon.agent_radius

	#for cell: Vector2i in tilemap.get_used_cells(0):
		#var tile_data: TileData = tilemap.get_cell_tile_data(0, cell)
		#if not tile_data:
			#continue
#
		#if tile_data.get_navigation_polygon(0) or tile_data.get_navigation_polygon(1): # Flying units can move on short world objects and the same tiles as the ground units
			#flying_units_navigation_tilemap.set_cell(0, cell, 0)

	# Create the source geometry resource that will hold the parsed geometry data.
	var source_geometry_data: NavigationMeshSourceGeometryData2D = NavigationMeshSourceGeometryData2D.new()
	# Add outline(s) for what is traversable navigation mesh surface for your flying units.
	# This can also be the outlines of an existing NavigationPolygon that you did draw in the Editor for your flying units.
	# You can get those drawn outlines with the NavigationPolygon.get_outline_count() and NavigationPolygon.get_outline(idx: int) functions.
	#for cell: Vector2i in tilemap.get_used_cells(0):
		#var tile_data: TileData = tilemap.get_cell_tile_data(0, cell)
		#if not tile_data:
			#continue
#
		#var tile_navigation_polygon_flying_units: NavigationPolygon = tile_data.get_navigation_polygon(1)
		#if tile_navigation_polygon_flying_units:
			#for outline_index: int in tile_navigation_polygon_flying_units.get_outline_count():
				#var outline: PackedVector2Array = tile_navigation_polygon_flying_units.get_outline(outline_index)
				#var outline_array: Array[Vector2] = []
				#for outline_point: Vector2 in outline:
					#var pos_to_add: Vector2 = cell * Rooms.TILE_SIZE
					#outline_point += pos_to_add
					#outline_array.push_back(outline_point)
				#var packed_ouline_array: PackedVector2Array = PackedVector2Array(outline_array)
				#source_geometry_data.add_traversable_outline(packed_ouline_array)

	# Parse the source geometry from the scene tree on the main thread.
	# The navigation mesh in this is only required for the parse settings.
	#print_debug(source_geometry_data.traversable_outlines)
	NavigationServer2D.parse_source_geometry_data(navigation_mesh_flying_units, source_geometry_data, self)

	# Bake the navigation geometry for the agent size from the source geometry.
	# If required for performance this baking step could also be done on background threads with bake_from_source_geometry_data_async()
	NavigationServer2D.bake_from_source_geometry_data(navigation_mesh_flying_units, source_geometry_data)

	# Create different navigation maps on the NavigationServer.
	navigation_map_flying_units = NavigationServer2D.map_create()

	NavigationServer2D.map_set_cell_size(navigation_map_flying_units, 1.0)

	# Set the new navigation map as active.
	NavigationServer2D.map_set_active(navigation_map_flying_units, true)

	# Create a region for the map.
	navigation_region_flying_units = NavigationServer2D.region_create()

	# Add the region to the map.
	NavigationServer2D.region_set_map(navigation_region_flying_units, navigation_map_flying_units)

	# Set navigation mesh for the region.
	NavigationServer2D.region_set_navigation_polygon(navigation_region_flying_units, navigation_mesh_flying_units)


func _free_navigation() -> void:
	if navigation_map_flying_units.is_valid():
		NavigationServer2D.free_rid(navigation_map_flying_units)
	if navigation_region_flying_units.is_valid():
		NavigationServer2D.free_rid(navigation_region_flying_units)
