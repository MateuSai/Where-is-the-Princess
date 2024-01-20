extends StaticBody2D

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

const COST: int = 10

var item_on_floor_1: ItemOnFloor
var item_on_floor_2: ItemOnFloor

@export var flip_h: bool = false
@export var dir: Vector2 = Vector2(0, 1)

@onready var interact_area: InteractArea = $InteractArea
@onready var cost_hbox: HBoxContainer = $CostHBox


func _ready() -> void:
	($AnimatedSprite as AnimatedSprite2D).flip_h = flip_h

	cost_hbox.hide()

	interact_area.body_entered.connect(func(_player: Player) -> void:
		cost_hbox.show()
		if SavedData.run_stats.coins >= COST:
			interact_area.sprite_material.set("shader_parameter/color", Color.WHITE)
			# interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
		else:
			interact_area.sprite_material.set("shader_parameter/color", Color.RED)
			interact_area.sprite_material.set("shader_parameter/interior_color", Color("#8f20178d"))
	)
	interact_area.body_exited.connect(func(_player: Player) -> void:
		cost_hbox.hide()
		if not SavedData.run_stats.coins >= COST:
			interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
	)

	interact_area.player_interacted.connect(func() -> void:
		if SavedData.run_stats.coins < COST:
			return

		SavedData.run_stats.coins -= COST
		interact_area.queue_free()
		var possible_rune_items: Array[WeaponModifier] = [Ruby.new(), Sapphire.new(), Topaz.new()]
		var possible_arrow_items: Array[ArrowModifier] = [BouncingArrowModifier.new(), ExplosiveArrowModifier.new(), HomingArrowModifier.new(), PiercingArrowModifier.new()]
		possible_rune_items.shuffle()
		possible_arrow_items.shuffle()
		item_on_floor_1 = _spawn_item(possible_rune_items.pop_back() as WeaponModifier, position + Vector2(10, -8).rotated(dir.angle()))
		item_on_floor_2 = _spawn_item(possible_arrow_items.pop_back() as ArrowModifier, position + Vector2(10, 8).rotated(dir.angle()))
		item_on_floor_1.interact_area.player_interacted.connect(_on_item_1_interacted)
		item_on_floor_2.interact_area.player_interacted.connect(_on_item_2_interacted)
	)


func _on_item_1_interacted() -> void:
	item_on_floor_1.interact_area.player_interacted.disconnect(_on_item_1_interacted)
	_remove_item(item_on_floor_2)


func _on_item_2_interacted() -> void:
	item_on_floor_2.interact_area.player_interacted.disconnect(_on_item_2_interacted)
	_remove_item(item_on_floor_1)


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
