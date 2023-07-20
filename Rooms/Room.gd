class_name DungeonRoom extends Node2D

@export var boss_room: bool = false

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

const ENEMY_SCENES: Dictionary = {
	#"FLYING_CREATURE": preload("res://Characters/Enemies/Flying Creature/FlyingCreature.tscn"),
	#"GOBLIN": preload("res://Characters/Enemies/Goblin/Goblin.tscn"),
	#"DARK_GOBLIN": preload("res://Characters/Enemies/DarkGoblin/DarkGoblin.tscn"),
	#"SHIELD_KNIGHT": preload("res://Characters/Enemies/ShieldKnight/ShieldKnight.tscn"),
	"MOLE": preload("res://Characters/Enemies/Mole/Mole.tscn"),
}

const HORIZONTAL_UP_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/HorizontalUpDoor.tscn")
const HORIZONTAL_DOWN_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/HorizontalDownDoor.tscn")
const VERTICAL_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/VerticalDoor.tscn")

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
@onready var vector_to_center: Vector2 = tilemap.get_used_rect().position * Rooms.TILE_SIZE + tilemap.get_used_rect().size * Rooms.TILE_SIZE / 2
@onready var radius: float = (vector_to_center - Vector2(tilemap.get_used_rect().position * Rooms.TILE_SIZE)).length() * 1
@onready var entries: Array[Node] = [get_node("Entries/Left"), get_node("Entries/Up"), get_node("Entries/Right"), get_node("Entries/Down")]
@onready var door_container: Node2D = get_node("Doors")
@onready var enemy_positions_container: Node2D = get_node("EnemyPositions")


func _ready() -> void:
	num_enemies = enemy_positions_container.get_child_count()


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


func has_entry(dir: EntryDirection) -> bool:
	var direction_entries: Array[Node] = entries[dir].get_children()
#	for entry in used_entries:
#		if direction_entries.has(entry):
#			direction_entries.erase(entry)

	return direction_entries.size() > 0


func get_entry_position(dir: EntryDirection) -> Vector2:
	return entries[dir].get_children()[0].global_position


func get_random_entry(dir: EntryDirection) -> Node:
	var direction_entries: Array[Node] = entries[dir].get_children()
#	for entry in used_entries:
#		if direction_entries.has(entry):
#			direction_entries.erase(entry)

	if direction_entries.is_empty():
		return null
	else:
		var rand_entry: Node = direction_entries[randi() % direction_entries.size()]
		used_entries.push_back(rand_entry)
		return rand_entry


func add_doors_and_walls(corridor_tilemap: TileMap) -> void:
	for dir in [EntryDirection.LEFT, EntryDirection.RIGHT]:
		for entry in entries[dir].get_children():
			if entry in used_entries:
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
					if tilemap.get_cell_atlas_coords(0, tile_positions[0] + Vector2i.UP * 3) == Vector2i(-1, -1):
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, Rooms.ATLAS_ID, Rooms.UPPER_WALL_LEFT_CORNER_COOR)
					else:
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, Rooms.ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0] + Vector2i.UP, Rooms.ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0], Rooms.ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1], Rooms.ATLAS_ID, Rooms.LEFT_WALL_COOR)
				else:
					if tilemap.get_cell_atlas_coords(0, tile_positions[0] + Vector2i.UP * 3) == Vector2i(-1, -1):
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, Rooms.ATLAS_ID, Rooms.UPPER_WALL_RIGHT_CORNER_COOR)
					else:
						tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, Rooms.ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0] + Vector2i.UP, Rooms.ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0], Rooms.ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1], Rooms.ATLAS_ID, Rooms.RIGHT_WALL_COOR)
	for dir in [EntryDirection.UP, EntryDirection.DOWN]:
		for entry in entries[dir].get_children():
			if entry in used_entries:
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
					tilemap.set_cell(0, tile_positions[0] + Vector2i.LEFT, Rooms.ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0], Rooms.ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1], Rooms.ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1] + Vector2i.RIGHT, Rooms.ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0] + Vector2i.DOWN, Rooms.ATLAS_ID, Rooms.FULL_WALL_COORDS[randi() % Rooms.FULL_WALL_COORDS.size()])
					tilemap.set_cell(0, tile_positions[1] + Vector2i.DOWN, Rooms.ATLAS_ID, Rooms.FULL_WALL_COORDS[randi() % Rooms.FULL_WALL_COORDS.size()])
				else:
					tilemap.set_cell(1, tile_positions[0] + Vector2i.LEFT, Rooms.ATLAS_ID, Rooms.BOTTOM_WALL_COOR)
					tilemap.set_cell(1, tile_positions[0], Rooms.ATLAS_ID, Rooms.BOTTOM_WALL_COOR)
					tilemap.set_cell(1, tile_positions[1], Rooms.ATLAS_ID, Rooms.BOTTOM_WALL_COOR)
					tilemap.set_cell(1, tile_positions[1] + Vector2i.RIGHT, Rooms.ATLAS_ID, Rooms.BOTTOM_WALL_COOR)

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
	if num_enemies > 0:
		_close_entrance()
		_spawn_enemies()
		closed.emit()
		Globals.room_closed.emit()
	else:
		pass
		#_close_entrance()
		#_open_doors()


func get_random_circle_spawn_point(circle_radius: float) -> Vector2:
	var directions_with_entry: Array[EntryDirection] = []
	for dir in [EntryDirection.LEFT, EntryDirection.UP, EntryDirection.RIGHT, EntryDirection.DOWN]:
		if has_entry(dir):
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

#	var t: float = 2 * PI * randf()
#	var u: float = randf() + randf()
#	var r = null
#	if u > 1:
#		r = 2 - u
#	else:
#		r = u
#
#	return Vector2(radius * r * cos(t), radius * r * sin(t))


func get_rect() -> Rect2:
	return Rect2(Vector2i(position) + (tilemap.get_used_rect().position * 16), (tilemap.get_used_rect().size * 16))
