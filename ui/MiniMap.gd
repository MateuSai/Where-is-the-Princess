class_name MiniMap extends Control

const TILE_SIZE: int = 4

# Why is this thig negative? I have no idea but it works somehow
const TOP_MARGIN: int = -16

var tileset: TileSet = TileSet.new()
var room_tilemaps: Array[TileMap] = []
var rooms_items_ui: Array[ItemsUI] = []

var room_selected: DungeonRoom = null

var map_rect: Rect2 = Rect2(0, 0, 0, 0)

#var corridors_tilemap_duplicate: TileMap
#var fog_image: Image = Image.new()
var fog_sprite: Sprite2D
#var fog_image: Image

@onready var ui: GameUI = %UI
@onready var rooms: Rooms = $"../../../Rooms"
@onready var real_fog_sprite: Sprite2D = %FogSprite
@onready var scroll_container: ScrollContainer = $MinimapScrollContainer
@onready var container: MarginContainer = $MinimapScrollContainer/PanelContainer/MarginContainer
@onready var map_name_label: Label = $MinimapScrollContainer/PanelContainer/MapNameLabel
@onready var player_icon: Sprite2D = $MinimapScrollContainer/PanelContainer/PlayerIcon

#@onready var update_fog_timer: Timer = $UpdateFogTimer
#@onready var tilemap: TileMap = $TileMap

func _ready() -> void:
	set_process(false)

	draw.connect(func() -> void:
		scroll_to_player()
		set_process(true)
		_on_draw()
	)
	hidden.connect(func() -> void:
		set_process(false)
		_on_hide()
	)

	#update_fog_timer.timeout.connect(_update_fog)

func set_up() -> void:
	rooms.room_visited.connect(_discover_room)

	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
	atlas.texture = load(SavedData.get_biome_conf().minimap_texture)
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	@warning_ignore("integer_division")
	var width_tiles: int = atlas.texture.get_width() / TILE_SIZE
	@warning_ignore("integer_division")
	var height_tiles: int = atlas.texture.get_height() / TILE_SIZE
	for i: int in width_tiles:
		for j: int in height_tiles:
			atlas.create_tile(Vector2i(i, j))
	tileset.add_source(atlas)

	room_tilemaps.resize(rooms.rooms.size())
	rooms_items_ui.resize(rooms.rooms.size())

	var minimap_corridors_tilemap: TileMap = TileMap.new()
	var world_corridor_tilemap: TileMap = $"../../../Rooms/CorridorTileMap"

	for layer_i: int in world_corridor_tilemap.get_layers_count():
		minimap_corridors_tilemap.add_layer(layer_i)
		minimap_corridors_tilemap.set_layer_z_index(layer_i, world_corridor_tilemap.get_layer_z_index(layer_i) + 2)

	minimap_corridors_tilemap.tile_set = tileset
	_copy_tiles(world_corridor_tilemap, minimap_corridors_tilemap)
	container.add_child(minimap_corridors_tilemap)

	fog_sprite = Sprite2D.new()
	var fog_sprite_material: ShaderMaterial = ShaderMaterial.new()
	fog_sprite_material.shader = load("res://shaders_and_particles/IntensityToTransparency.gdshader")
	fog_sprite_material.set("shader_parameter/color", Color("ceae6f"))
	fog_sprite.material = fog_sprite_material
	fog_sprite.centered = false
	fog_sprite.z_index = 10
	#fog_sprite.offset = Vector2.ONE * rooms.FOG_PADDING
	fog_sprite.position.y += - TOP_MARGIN
	#fog_sprite.scale /= content_scale_factor
	map_rect = Rect2(0, 0, 0, 0)
	for room: DungeonRoom in rooms.rooms:
		var room_rect: Rect2 = room.get_rect()
		room_rect.position /= 4
		room_rect.size /= 4
		map_rect = map_rect.merge(room_rect)
	map_rect.position.y += TOP_MARGIN
	map_rect.size.y += - TOP_MARGIN

	#fog_image = Image.create(map_rect.size.x, map_rect.size.y, false, Image.FORMAT_RGBH)

	minimap_corridors_tilemap.position = -map_rect.position # + Vector2(size.x / 2.0, 0)
	#container.position = map_rect.position / content_scale_factor
#	size = (map_rect.size + Vector2(80, 0)).clamp(Vector2.ZERO, Vector2(330, 200))
#	$MinimapScrollContainer.custom_minimum_size = size
#	$MinimapScrollContainer.size = size
	container.custom_minimum_size = map_rect.size

	#fog_sprite.position = Vector2(size.x / 2.0, 0)
	#print(fog_sprite.position)

	#@warning_ignore("narrowing_conversion")
#	fog_image = Image.create(entire_map_rect.size.x, entire_map_rect.size.y, false, Image.FORMAT_RGBAH)
#	fog_image.fill(Color.BLACK)
	#fog_sprite.position = map_rect.position + Vector2(size.x/2.0, 0)
	container.add_child(fog_sprite)
	#fog_sprite.hide()

	map_name_label.text = SavedData.get_biome_conf().name
	#map_name_label.position = Vector2.ZERO

	#await owner.player_added

	#visibility_changed.connect(func() -> void:
		#if visible:
			#_on_draw()
		#else:
			#_on_hide()
	#)

func clear() -> void:
	for i: int in range(container.get_child_count() - 1, -1, -1):
		container.get_child(i).free()

func _on_draw() -> void:
	_update_fog()
	#update_fog_timer.start()

	for i: int in rooms_items_ui.size():
		var items_ui: ItemsUI = rooms_items_ui[i]
		if items_ui != null:
			items_ui.clear()
			items_ui.update_items(rooms.rooms[i].get_items())
			items_ui.update_weapons(rooms.rooms[i].get_weapons())

	set_process_input(true)

func _on_hide() -> void:
	#update_fog_timer.stop()

	set_process_input(false)

func _update_fog() -> void:
	if not is_instance_valid(Globals.player):
		return

	if real_fog_sprite.texture:
		var world_fog_image: Image = real_fog_sprite.texture.get_image()
		world_fog_image = world_fog_image.get_region(Rect2(Vector2i.ONE * rooms.FOG_PADDING, world_fog_image.get_size() - Vector2i.ONE * rooms.FOG_PADDING * 2))
		#world_fog_image.crop(world_fog_image.get_width() - rooms.FOG_PADDING * 2, world_fog_image.get_height() - rooms.FOG_PADDING * 2)
		world_fog_image.shrink_x2()
		world_fog_image.shrink_x2()
		fog_sprite.texture = ImageTexture.create_from_image(world_fog_image)
#		var light: Image = load("res://Art/light_fire.png").get_image()
#		light.convert(Image.FORMAT_RGBAH)
#		# light.resize(light.get_width() * 5, light.get_height() * 5)
#		fog_image.blend_rect(light, Rect2(Vector2.ZERO, light.get_size()), Globals.player.position - entire_map_rect.position - light.get_size()/2.0)
#		fog_sprite.texture = ImageTexture.create_from_image(fog_image)

func _input(event: InputEvent) -> void:
	if room_selected != null:
		if event is InputEventMouseButton:
			if event.is_pressed() and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
				Globals.player.position = room_selected.position + (room_selected.get_node("TeleportPosition") as Marker2D).position
				ui.hide_tab_container()

func _process(_delta: float) -> void:
	if room_selected == null:
		for i: int in room_tilemaps.size():
			if room_tilemaps[i] == null or not rooms.rooms[i] in rooms.visited_rooms:
				continue
			var room_tilemap: TileMap = room_tilemaps[i]
#			print(container.get_local_mouse_position())
#			print(Rect2(room_tilemap.position + Vector2(room_tilemap.get_used_rect().position * TILE_SIZE), room_tilemap.get_used_rect().size * TILE_SIZE))
			if Rect2(room_tilemap.position + Vector2(room_tilemap.get_used_rect().position * TILE_SIZE), room_tilemap.get_used_rect().size * TILE_SIZE).has_point(container.get_local_mouse_position()) and get_global_rect().has_point(get_global_mouse_position()):
				room_selected = rooms.rooms[i]
				room_tilemap.modulate = Color.GRAY
	else:
		var room_tilemap: TileMap = room_tilemaps[rooms.rooms.find(room_selected)]
		if not Rect2(room_tilemap.position + Vector2(room_tilemap.get_used_rect().position * TILE_SIZE), room_tilemap.get_used_rect().size * TILE_SIZE).has_point(container.get_local_mouse_position()) or not get_global_rect().has_point(get_global_mouse_position()):
			room_selected = null
			room_tilemap.modulate = Color.WHITE
#	print(container.get_local_mouse_position())
#		print(room_tilemaps[1].position)

	player_icon.position = Globals.player.position / 4 - map_rect.position + Vector2.ONE * 4 * TILE_SIZE

func scroll_to_player() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	@warning_ignore("narrowing_conversion")
	scroll_container.scroll_horizontal = player_icon.position.x - size.x / 2.0
	@warning_ignore("narrowing_conversion")
	scroll_container.scroll_vertical = player_icon.position.y - size.y / 2.0

func _discover_room(room: DungeonRoom) -> void:
	var world_room_tilemap: TileMap = room.tilemap
	var minimap_room_tilemap: TileMap = TileMap.new()

	for layer_i: int in world_room_tilemap.get_layers_count():
		minimap_room_tilemap.add_layer(layer_i)
		minimap_room_tilemap.set_layer_z_index(layer_i, world_room_tilemap.get_layer_z_index(layer_i) + 4)

	minimap_room_tilemap.tile_set = tileset
	_copy_tiles(world_room_tilemap, minimap_room_tilemap)
	#minimap_room_tilemap.position = room.position/4
	container.add_child(minimap_room_tilemap)
	# I substract 1 because the first tilemap is the corridors tilemap, not a room
	room_tilemaps[int(room.name.right(1))] = minimap_room_tilemap

	minimap_room_tilemap.position = room.position / 4 - map_rect.position # + Vector2(size.x / 2.0, 0)

	var items_ui_container: Node2D = Node2D.new() # Otherwise the HBox will adapt to the MarginContainer
	var items_ui: ItemsUI = ItemsUI.new()
	items_ui.size = minimap_room_tilemap.get_used_rect().size * TILE_SIZE
	rooms_items_ui[int(room.name.right(1))] = items_ui
	items_ui_container.add_child(items_ui)
	container.add_child(items_ui_container)

	items_ui.position = room.position / 4 + Vector2(room.tilemap_offset) / 4 - map_rect.position

func _copy_tiles(from: TileMap, to: TileMap) -> void:
	for layer: int in from.get_layers_count():
		for cell: Vector2i in from.get_used_cells(layer):
			to.set_cell(layer, cell, 0, from.get_cell_atlas_coords(layer, cell))

class ItemsUI extends MarginContainer:
	var hflow: HFlowContainer

	func _init() -> void:
		z_index = 50
		add_theme_constant_override("margin_left", 8)
		add_theme_constant_override("margin_top", 8)
		add_theme_constant_override("margin_right", 8)
		add_theme_constant_override("margin_bottom", 8)

	func _ready() -> void:
		hflow = HFlowContainer.new()
		hflow.alignment = HFlowContainer.ALIGNMENT_CENTER
		hflow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		add_child(hflow)

	func clear() -> void:
		for i: int in range(hflow.get_child_count() - 1, -1, -1):
			hflow.get_child(i).free()

	func update_items(items: Array[ItemOnFloor]) -> void:
		for item: ItemOnFloor in items:
			var icon: TextureRect = TextureRect.new()
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
			icon.texture = item.item.get_icon()
			hflow.add_child(icon)

	func update_weapons(weapons: Array[Weapon]) -> void:
		#for weapon: Weapon in weapons:
		if not weapons.is_empty():
			var icon: TextureRect = TextureRect.new()
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
			#icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			#icon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
			#icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
			icon.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/sword_icon.png")
			hflow.add_child(icon)
