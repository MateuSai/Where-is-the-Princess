class_name Crate extends StaticBody2D

const EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

@onready var room: DungeonRoom = get_parent()

@onready var sprite: Sprite2D = $Sprite2D
@onready var life_component: LifeComponent = $LifeComponent
@onready var shake_component: ShakeComponent = $ShakeComponent


func _ready() -> void:
	life_component.died.connect(func() -> void:
		sprite.frame = (randi() % 3) + 1
		var explosion: AnimatedSprite2D = EXPLOSION_SCENE.instantiate()
		explosion.position = global_position
		get_tree().current_scene.add_child(explosion)
	)

	life_component.damage_taken.connect(func(_dam: int, dir: Vector2, _force: int) -> void:
		shake_component.shake(sprite)
		if life_component.hp == 0:
			_spawn_wood_fragments(dir)
			if randi() % 7 == 0:
				var item_on_floor: ItemOnFloor = preload("res://items/item_on_floor.tscn").instantiate()
				var food: Food = Food.new()
				room.add_item_on_floor(item_on_floor, position + Vector2(randf_range(-8, 8), randf_range(-8, 8)))
				item_on_floor.initialize(food)
				item_on_floor.enable_pick_up()
	)


func _spawn_wood_fragments(dir: Vector2) -> void:
	var wood_fragment_scene: PackedScene = load("res://Rooms/Furniture and Traps/wood_fragment.tscn")

	var amount: int = randi_range(4, 10)
	for i: int in amount:
		var wood_fragment: WoodFragment = wood_fragment_scene.instantiate()
		wood_fragment.position = position
		room.add_child(wood_fragment)
		wood_fragment.throw(dir.rotated(randf_range(-1.0, 1.0)))
