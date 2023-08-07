class_name MiniMap extends Popup

var room_tilemaps: Array[TileMap] = []

var room_selected: DungeonRoom = null

var map_rect: Rect2 = Rect2(0, 0, 0, 0)

var corridors_tilemap_duplicate: TileMap
#var fog_image: Image = Image.new()
var fog_sprite: Sprite2D

@onready var rooms: Rooms = $"../../Rooms"
@onready var container: Control = $ScrollContainer/Control
#@onready var tilemap: TileMap = $TileMap


func _ready() -> void:
	set_process(false)
	popup_hide.connect(func(): set_process(false))

	rooms.room_visited.connect(_discover_room)

	await owner.player_added

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

	fog_sprite = Sprite2D.new()
	var fog_sprite_material: CanvasItemMaterial = CanvasItemMaterial.new()
	fog_sprite_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	fog_sprite_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	fog_sprite.material = fog_sprite_material
	fog_sprite.centered = false
	fog_sprite.z_index = 10
	#fog_sprite.scale /= content_scale_factor
	var entire_map_rect: Rect2 = Rect2(0, 0, 0, 0)
	for room in rooms.rooms:
		entire_map_rect = entire_map_rect.merge(room.get_rect())
	#@warning_ignore("narrowing_conversion")
#	fog_image = Image.create(entire_map_rect.size.x, entire_map_rect.size.y, false, Image.FORMAT_RGBAH)
#	fog_image.fill(Color.BLACK)
	fog_sprite.position = entire_map_rect.position + Vector2(size.x/2.0, 0)
	container.add_child(fog_sprite)

	while is_instance_valid(Globals.player):
		fog_sprite.texture = $"../../FogSprite".texture
#		var light: Image = load("res://Art/light_fire.png").get_image()
#		light.convert(Image.FORMAT_RGBAH)
#		# light.resize(light.get_width() * 5, light.get_height() * 5)
#		fog_image.blend_rect(light, Rect2(Vector2.ZERO, light.get_size()), Globals.player.position - entire_map_rect.position - light.get_size()/2.0)
#		fog_sprite.texture = ImageTexture.create_from_image(fog_image)
		await get_tree().create_timer(0.5).timeout

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
	var previous_map_rect: Rect2 = map_rect
	map_rect = map_rect.merge(room_rect)
	if room != rooms.start_room:
		fog_sprite.position += map_rect.size - previous_map_rect.size

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
