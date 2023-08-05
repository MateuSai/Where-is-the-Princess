class_name MiniMap extends Popup

var room_tilemaps: Array[TileMap] = []

var room_selected: DungeonRoom = null

var map_rect: Rect2 = Rect2(0, 0, 0, 0)

var corridors_tilemap_duplicate: TileMap

@onready var rooms: Rooms = $"../../Rooms"
@onready var container: Control = $ScrollContainer/Control
#@onready var tilemap: TileMap = $TileMap


func _ready() -> void:
	set_process(false)
	popup_hide.connect(func(): set_process(false))

	rooms.room_visited.connect(_discover_room)

	await rooms.generation_completed

	room_tilemaps.resize(rooms.rooms.size())

#	for room in rooms.rooms:
#		var room_rect: Rect2 = room.get_rect()
#		# print(room_rect)
#		map_rect = map_rect.merge(room_rect)
#
#		var room_tilemap_duplicate: TileMap = room.tilemap.duplicate()
#		room_tilemap_duplicate.position = room.position
#		container.add_child(room_tilemap_duplicate)
#		room_tilemaps.push_back(room_tilemap_duplicate)

#		var area_to_detect_mouse: Area2D = Area2D.new()
#		var area_collision_shape: CollisionShape2D = CollisionShape2D.new()
#		var area_shape: RectangleShape2D = RectangleShape2D.new()
#		area_shape.size = room_rect.size
#		area_collision_shape.shape = area_shape
#		area_to_detect_mouse.add_child(area_collision_shape)
#		room_tilemap_duplicate.add_child(area_to_detect_mouse)
#		area_to_detect_mouse.mouse_entered.connect(func():
#			print("dsdfsd")
#		)
#		var origin_tile_coordinate: Vector2i = tilemap.local_to_map(room.position)
#		var room_tilemap: TileMap = room.tilemap
#		for layer in room_tilemap.get_layers_count():
#			for cell in room_tilemap.get_used_cells(layer):
#				tilemap.set_cell(layer, origin_tile_coordinate + cell, room_tilemap.get_cell_source_id(layer, cell), room_tilemap.get_cell_atlas_coords(layer, cell))

	corridors_tilemap_duplicate = $"../../Rooms/CorridorTileMap".duplicate()
	container.add_child(corridors_tilemap_duplicate)

#	#print(map_rect)
#	for tilemap in container.get_children():
#		tilemap.position += -map_rect.position + Vector2(size.x / 2.0, 0)
#	#container.position = map_rect.position / content_scale_factor
#	container.custom_minimum_size = map_rect.size


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_minimap"):
		hide()

	if room_selected != null:
		if event is InputEventMouseButton:
			if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
				Globals.player.position = room_selected.position + room_selected.get_node("TeleportPosition").position
				hide()



func _process(_delta: float) -> void:
	if room_selected == null:
		for i in room_tilemaps.size():
			if room_tilemaps[i] == null or not rooms.rooms[i] in rooms.visited_rooms:
				continue
			var room_tilemap: TileMap = room_tilemaps[i]
			if Rect2(room_tilemap.position + Vector2(room_tilemap.get_used_rect().position * Rooms.TILE_SIZE), room_tilemap.get_used_rect().size * Rooms.TILE_SIZE).has_point(container.get_local_mouse_position()):
				room_selected = rooms.rooms[i]
				room_tilemap.modulate = Color.GRAY
	else:
		var room_tilemap: TileMap = room_tilemaps[rooms.rooms.find(room_selected)]
		if not Rect2(room_tilemap.position + Vector2(room_tilemap.get_used_rect().position * Rooms.TILE_SIZE), room_tilemap.get_used_rect().size * Rooms.TILE_SIZE).has_point(container.get_local_mouse_position()):
			room_selected = null
			room_tilemap.modulate = Color.WHITE
#		print(container.get_local_mouse_position())
#		print(room_tilemaps[1].position)


func _discover_room(room: DungeonRoom) -> void:
	var room_rect: Rect2 = room.get_rect()
	# print(room_rect)
	map_rect = map_rect.merge(room_rect)

	var room_tilemap_duplicate: TileMap = room.tilemap.duplicate()
	room_tilemap_duplicate.position = room.position
	container.add_child(room_tilemap_duplicate)
	# I substract 1 because the first tilemap is the corridors tilemap, not a room
	room_tilemaps[room.get_index() - 1] = room_tilemap_duplicate

	_update_minimap()


func _update_minimap() -> void:
	for i in room_tilemaps.size():
		var tilemap: TileMap = room_tilemaps[i]
		if tilemap == null:
			continue
		tilemap.position = rooms.rooms[i].position -map_rect.position + Vector2(size.x / 2.0, 0)
	corridors_tilemap_duplicate.position = -map_rect.position + Vector2(size.x / 2.0, 0)
	#container.position = map_rect.position / content_scale_factor
	container.custom_minimum_size = map_rect.size
