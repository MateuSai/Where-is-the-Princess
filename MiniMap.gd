class_name MiniMap extends Popup

@onready var rooms: Rooms = $"../../Rooms"
@onready var container: Node2D = $Container
#@onready var tilemap: TileMap = $TileMap


func _ready() -> void:
	await rooms.generation_completed

	for room in rooms.rooms:
		var room_tilemap_duplicate: TileMap = room.tilemap.duplicate()
		room_tilemap_duplicate.position = room.position
		container.add_child(room_tilemap_duplicate)
#		var origin_tile_coordinate: Vector2i = tilemap.local_to_map(room.position)
#		var room_tilemap: TileMap = room.tilemap
#		for layer in room_tilemap.get_layers_count():
#			for cell in room_tilemap.get_used_cells(layer):
#				tilemap.set_cell(layer, origin_tile_coordinate + cell, room_tilemap.get_cell_source_id(layer, cell), room_tilemap.get_cell_atlas_coords(layer, cell))
