class_name MiniMap extends Popup

const TILE_SIZE: int = 4

var tileset: TileSet = TileSet.new()
var room_tilemaps: Array[TileMap] = []

var room_selected: DungeonRoom = null

var map_rect: Rect2 = Rect2(0, 0, 0, 0)

#var corridors_tilemap_duplicate: TileMap
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

	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
	atlas.texture = load(SavedData.get_biome_conf().minimap_texture)
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for i in atlas.texture.get_width()/TILE_SIZE:
		for j in atlas.texture.get_height()/TILE_SIZE:
			atlas.create_tile(Vector2i(i, j))
	tileset.add_source(atlas)

	room_tilemaps.resize(rooms.rooms.size())

	var minimap_corridors_tilemap: TileMap = TileMap.new()
	minimap_corridors_tilemap.add_layer(0)
	minimap_corridors_tilemap.add_layer(1)
	minimap_corridors_tilemap.tile_set = tileset
	var world_corridor_tilemap: TileMap = $"../../Rooms/CorridorTileMap"
	_copy_tiles(world_corridor_tilemap, minimap_corridors_tilemap)
	container.add_child(minimap_corridors_tilemap)

	fog_sprite = Sprite2D.new()
	var fog_sprite_material: CanvasItemMaterial = CanvasItemMaterial.new()
	fog_sprite_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	fog_sprite_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	fog_sprite.material = fog_sprite_material
	fog_sprite.centered = false
	fog_sprite.z_index = 10
	#fog_sprite.scale /= content_scale_factor
	map_rect = Rect2(0, 0, 0, 0)
	for room in rooms.rooms:
		var room_rect: Rect2 = room.get_rect()
		room_rect.position /= 4
		room_rect.size /= 4
		map_rect = map_rect.merge(room_rect)

	minimap_corridors_tilemap.position = -map_rect.position# + Vector2(size.x / 2.0, 0)
	#container.position = map_rect.position / content_scale_factor
	container.custom_minimum_size = map_rect.size

	#fog_sprite.position = Vector2(size.x / 2.0, 0)
	#print(fog_sprite.position)

	#@warning_ignore("narrowing_conversion")
#	fog_image = Image.create(entire_map_rect.size.x, entire_map_rect.size.y, false, Image.FORMAT_RGBAH)
#	fog_image.fill(Color.BLACK)
	#fog_sprite.position = map_rect.position + Vector2(size.x/2.0, 0)
	container.add_child(fog_sprite)
	#fog_sprite.hide()

	while is_instance_valid(Globals.player):
		if $"../../FogSprite".texture:
			var world_fog_image: Image = $"../../FogSprite".texture.get_image()
			world_fog_image.shrink_x2()
			world_fog_image.shrink_x2()
			fog_sprite.texture = ImageTexture.create_from_image(world_fog_image)
	#		var light: Image = load("res://Art/light_fire.png").get_image()
	#		light.convert(Image.FORMAT_RGBAH)
	#		# light.resize(light.get_width() * 5, light.get_height() * 5)
	#		fog_image.blend_rect(light, Rect2(Vector2.ZERO, light.get_size()), Globals.player.position - entire_map_rect.position - light.get_size()/2.0)
	#		fog_sprite.texture = ImageTexture.create_from_image(fog_image)
		await get_tree().create_timer(0.5).timeout


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
			if Rect2(room_tilemap.position + Vector2(room_tilemap.get_used_rect().position * TILE_SIZE), room_tilemap.get_used_rect().size * TILE_SIZE).has_point(container.get_local_mouse_position()):
				room_selected = rooms.rooms[i]
				room_tilemap.modulate = Color.GRAY
	else:
		var room_tilemap: TileMap = room_tilemaps[rooms.rooms.find(room_selected)]
		if not Rect2(room_tilemap.position + Vector2(room_tilemap.get_used_rect().position * TILE_SIZE), room_tilemap.get_used_rect().size * TILE_SIZE).has_point(container.get_local_mouse_position()):
			room_selected = null
			room_tilemap.modulate = Color.WHITE
#		print(container.get_local_mouse_position())
#		print(room_tilemaps[1].position)


func _discover_room(room: DungeonRoom) -> void:
	var world_room_tilemap: TileMap = room.tilemap
	var minimap_room_tilemap: TileMap = TileMap.new()
	minimap_room_tilemap.add_layer(0)
	minimap_room_tilemap.add_layer(1)
	minimap_room_tilemap.add_layer(2)
	minimap_room_tilemap.add_layer(3)
	minimap_room_tilemap.tile_set = tileset
	_copy_tiles(world_room_tilemap, minimap_room_tilemap)
	#minimap_room_tilemap.position = room.position/4
	container.add_child(minimap_room_tilemap)
	# I substract 1 because the first tilemap is the corridors tilemap, not a room
	room_tilemaps[room.get_index() - 1] = minimap_room_tilemap

	minimap_room_tilemap.position = room.position/4 -map_rect.position# + Vector2(size.x / 2.0, 0)


func _copy_tiles(from: TileMap, to: TileMap) -> void:
	for layer in from.get_layers_count():
		for cell in from.get_used_cells(layer):
			to.set_cell(layer, cell, 0, from.get_cell_atlas_coords(layer, cell))
