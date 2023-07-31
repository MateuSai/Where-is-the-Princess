class_name DungeonRoom extends Node2D

@export var boss_room: bool = false

## If empty, the room will appear on all the levels of the biome. If it has a number, the room will appear on the specified level. If it has a range, it will appear on all the levels inclusive. For example, [code]1-3[/code] will make the room appear on the levels 1, 2, and 3 of his biome.
## [br][br]
## If the value is invalid, an error will appear and the room will not be used
@export var levels: String = ""

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

const ENEMY_SCENES: Dictionary = {
	#"FLYING_CREATURE": preload("res://Characters/Enemies/Flying Creature/FlyingCreature.tscn"),
	#"GOBLIN": preload("res://Characters/Enemies/Goblin/Goblin.tscn"),
	#"DARK_GOBLIN": preload("res://Characters/Enemies/DarkGoblin/DarkGoblin.tscn"),
	#"SHIELD_KNIGHT": preload("res://Characters/Enemies/ShieldKnight/ShieldKnight.tscn"),
	# "MOLE": preload("res://Characters/Enemies/Mole/Mole.tscn"),
	# "SPIDER": preload("res://Characters/Enemies/Spider/Spider.tscn"),
	#"MARK": preload("res://Characters/Enemies/Mark the Reptilian/MarkTheReptilian.tscn"),
	"ARMORED_MARK": preload("res://Characters/Enemies/Armored Mark/ArmoredMark.tscn")
	#"SPIDER_EGG": preload("res://Characters/Enemies/Spider/SpiderEgg.tscn")
}

const HORIZONTAL_UP_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/HorizontalUpDoor.tscn")
const HORIZONTAL_DOWN_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/HorizontalDownDoor.tscn")
const VERTICAL_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/VerticalDoor.tscn")

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

signal closed()
signal cleared()

@onready var tilemap: TileMap = get_node("TileMap")
@onready var black_tilemap: TileMap = get_node("BlackTileMap")
@onready var vector_to_center: Vector2 = tilemap.get_used_rect().position * Rooms.TILE_SIZE + tilemap.get_used_rect().size * Rooms.TILE_SIZE / 2
@onready var radius: float = (vector_to_center - Vector2(tilemap.get_used_rect().position * Rooms.TILE_SIZE)).length() * 1
@onready var entries: Array[Node2D] = [get_node("Entries/Left"), get_node("Entries/Up"), get_node("Entries/Right"), get_node("Entries/Down")]
@onready var door_container: Node2D = get_node("Doors")
@onready var enemy_positions_container: Node2D = get_node("EnemyPositions")


func _ready() -> void:
	num_enemies = enemy_positions_container.get_child_count()

	ATLAS_ID = SavedData.get_biome_conf().room_atlas_id

	black_tilemap.modulate = ProjectSettings.get("rendering/environment/defaults/default_clear_color")
	for cell_pos in tilemap.get_used_cells(0):
		black_tilemap.set_cell(0, cell_pos, 0, Vector2i(0, 0))
	for cell_pos in tilemap.get_used_cells(1):
		black_tilemap.set_cell(0, cell_pos, 0, Vector2i(0, 0))

	if get_parent().get_parent().debug:
		black_tilemap.hide()


func _draw() -> void:
	pass
#	if get_parent().get_parent().debug:
#		draw_circle(vector_to_center, (vector_to_center - Vector2(tilemap.get_used_rect().position * Rooms.TILE_SIZE)).length(), Color.RED)


func get_separation_steering_dir(rooms: Array[DungeonRoom], delta: float) -> Vector2:
	var dir: Vector2 = Vector2.ZERO
	for room in rooms:
		if room == self:
			continue
		var vector_to_room: Vector2 = (room.position + room.vector_to_center) - (position + vector_to_center)
		if vector_to_room.length() < (radius + room.radius):
			dir += vector_to_room * (vector_to_room.length() - radius - room.radius)

	float_position += dir.normalized() * 500 * randf_range(0.9, 1.1) * delta
	position = round(float_position/Rooms.TILE_SIZE) * Rooms.TILE_SIZE

	return dir


func _has_entry(dir: EntryDirection) -> bool:
	var direction_entries: Array[Node] = entries[dir].get_children()
#	for entry in used_entries:
#		if direction_entries.has(entry):
#			direction_entries.erase(entry)

	return direction_entries.size() > 0


#func get_entry_position(dir: EntryDirection) -> Vector2:
#	return entries[dir].get_children()[0].global_position


func get_entries(dir: EntryDirection) -> Array[Node]:
	return entries[dir].get_children()


func get_random_entry(dir: EntryDirection, to_connect_to: Node = null) -> Node:
	var direction_entries: Array[Node] = entries[dir].get_children()
#	for entry in used_entries:
#		if direction_entries.has(entry):
#			direction_entries.erase(entry)

#	if direction_entries.is_empty():
#		return null
#	else:
	var usable_entries: Array[Node] = direction_entries.duplicate()

	if to_connect_to != null:
		usable_entries = usable_entries.filter(func(entry: Node2D):
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


func is_connection_between_entries_possible(this_room_entry: Node, this_room_entry_dir: EntryDirection, other_room_entry: Node) -> bool:
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
	for dir in [EntryDirection.LEFT, EntryDirection.RIGHT]:
		for entry in entries[dir].get_children():
			if entry in used_entries:
				black_tilemap.set_cell(0, black_tilemap.local_to_map(entry.position) + Vector2i.UP * 2)
				black_tilemap.set_cell(0, black_tilemap.local_to_map(entry.position) + Vector2i.UP)
				black_tilemap.set_cell(0, black_tilemap.local_to_map(entry.position))
				black_tilemap.set_cell(0, black_tilemap.local_to_map(entry.position) + Vector2i.DOWN)

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
				tile_positions.push_back(tilemap.local_to_map(entry.position + entry.get_child(0).position))
				tile_positions.push_back(tilemap.local_to_map(entry.position + entry.get_child(1).position))
				tilemap.erase_cell(3, tile_positions[1])
				if dir == EntryDirection.LEFT:
					if tilemap.get_cell_atlas_coords(0, tile_positions[0] + Vector2i.UP * 2 + Vector2i.RIGHT) == Rooms.UPPER_WALL_COOR:
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, ATLAS_ID, Rooms.UPPER_WALL_LEFT_CORNER_COOR)
					else:
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0] + Vector2i.UP, ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0], ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1], ATLAS_ID, Rooms.LEFT_WALL_COOR)
				else:
					if tilemap.get_cell_atlas_coords(0, tile_positions[0] + Vector2i.UP * 2 + Vector2i.LEFT) == Rooms.UPPER_WALL_COOR:
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, ATLAS_ID, Rooms.UPPER_WALL_RIGHT_CORNER_COOR)
					else:
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0] + Vector2i.UP, ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0], ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1], ATLAS_ID, Rooms.RIGHT_WALL_COOR)
	for dir in [EntryDirection.UP, EntryDirection.DOWN]:
		for entry in entries[dir].get_children():
			if entry in used_entries:
				black_tilemap.set_cell(0, black_tilemap.local_to_map(entry.position))
				black_tilemap.set_cell(0, black_tilemap.local_to_map(entry.position) + Vector2i.RIGHT)

				var horizontal_door: Door = HORIZONTAL_UP_DOOR.instantiate() if dir == EntryDirection.UP else HORIZONTAL_DOWN_DOOR.instantiate()
				horizontal_door.position = floor(entry.position / 16) * 16 + Vector2(Rooms.TILE_SIZE, Rooms.TILE_SIZE + 12)
				door_container.add_child(horizontal_door)
				if dir == EntryDirection.UP:
					corridor_tilemap.erase_cell(1, corridor_tilemap.local_to_map(entry.global_position) + Vector2i.UP)
					corridor_tilemap.erase_cell(1, corridor_tilemap.local_to_map(entry.global_position) + Vector2i.UP + Vector2i.RIGHT)
			else:
				var tile_positions: Array[Vector2i] = []
				tile_positions.push_back(tilemap.local_to_map(entry.position + entry.get_child(0).position))
				tile_positions.push_back(tilemap.local_to_map(entry.position + entry.get_child(1).position))
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

	for door in door_container.get_children():
		door.player_entered_room.connect(_on_player_entered_room)


func _on_enemy_killed() -> void:
	num_enemies -= 1
	if num_enemies == 0:
		await get_tree().process_frame
		cleared.emit()
		Globals.room_cleared.emit()
		_open_doors()


func _open_doors() -> void:
	for door in door_container.get_children():
		door.open()


func _close_entrance() -> void:
	for door in door_container.get_children():
		door.close()
#	for entry_position in entrance.get_children():
#		tilemap.set_cell(1, tilemap.local_to_map(entry_position.position), 1, Vector2i.ZERO)
#		tilemap.set_cell(1, tilemap.local_to_map(entry_position.position) + Vector2i.DOWN, 2, Vector2i.ZERO)


func _spawn_enemies() -> void:
	for enemy_position in enemy_positions_container.get_children():
		var enemy: CharacterBody2D
#		if boss_room:
#			enemy = ENEMY_SCENES.SLIME_BOSS.instantiate()
#			num_enemies = 15
		#else:
			#enemy = ENEMY_SCENES.SHIELD_KNIGHT.instantiate()
		enemy = ENEMY_SCENES.values()[randi() % ENEMY_SCENES.values().size()].instantiate()
#			if randi() % 2 == 0:
#				enemy = ENEMY_SCENES.FLYING_CREATURE.instantiate()
#			else:
#				enemy = ENEMY_SCENES.GOBLIN.instantiate()
		enemy.position = enemy_position.position
		call_deferred("add_child", enemy)

		var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
		spawn_explosion.position = enemy_position.position
		call_deferred("add_child", spawn_explosion)



func _on_player_entered_room() -> void:
	for door in door_container.get_children():
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


func get_random_circle_spawn_point(circle_radius: float) -> Vector2:
	var directions_with_entry: Array[EntryDirection] = []
	for dir in [EntryDirection.LEFT, EntryDirection.UP, EntryDirection.RIGHT, EntryDirection.DOWN]:
		if _has_entry(dir):
			directions_with_entry.push_back(dir)

	if directions_with_entry.size() == 4:
		return Vector2.RIGHT.rotated(randf_range(0, 2 * PI) * randf_range(0, circle_radius))
	else:
		var entries_dir: Vector2 = Vector2.ZERO
		for dir in directions_with_entry:
			entries_dir += [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN][dir]
		entries_dir *= -1
		#print(name + " " + str(entries_dir) + " " + str(directions_with_entry))
		return Vector2.RIGHT.rotated(randf_range(entries_dir.angle() - PI/8, entries_dir.angle() + PI/8)) * circle_radius


func get_rect() -> Rect2:
	return Rect2(Vector2i(position) + (tilemap.get_used_rect().position * 16), (tilemap.get_used_rect().size * 16))
