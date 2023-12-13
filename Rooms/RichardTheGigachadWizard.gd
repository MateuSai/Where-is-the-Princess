extends StaticBody2D

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

@onready var interact_area: InteractArea = $InteractArea


func _ready() -> void:
	interact_area.player_interacted.connect(func() -> void:
		interact_area.queue_free()
		var possible_items: Array[WeaponModifier] = [Ruby.new(), Sapphire.new(), Topaz.new()]
		possible_items.shuffle()
		var item_on_floor_1: ItemOnFloor = _spawn_item(possible_items.pop_back() as WeaponModifier, position + Vector2(-8, 10))
		var item_on_floor_2: ItemOnFloor = _spawn_item(possible_items.pop_back() as WeaponModifier, position + Vector2(8, 10))
		item_on_floor_1.interact_area.player_interacted.connect(func() -> void: _remove_item(item_on_floor_2))
		item_on_floor_2.interact_area.player_interacted.connect(func() -> void: _remove_item(item_on_floor_1))
	)


func _spawn_item(item: WeaponModifier, pos: Vector2) -> ItemOnFloor:
	var explosion: Node2D = SPAWN_EXPLOSION_SCENE.instantiate()
	explosion.position = pos
	get_parent().add_child(explosion)

	var item_on_floor: ItemOnFloor = (load("res://items/item_on_floor.tscn") as PackedScene).instantiate()
	item_on_floor.position = pos
	item_on_floor.initialize(item)
	get_parent().add_child(item_on_floor)
	item_on_floor.enable_pick_up()

	return item_on_floor


func _remove_item(item_on_floor: ItemOnFloor) -> void:
	var explosion: Node2D = SPAWN_EXPLOSION_SCENE.instantiate()
	explosion.position = item_on_floor.position
	get_parent().add_child(explosion)

	item_on_floor.queue_free()
