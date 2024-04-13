class_name Crate extends StaticBody2D

@onready var room: DungeonRoom = get_parent()

@onready var sprite: Sprite2D = $Sprite2D
@onready var life_component: LifeComponent = $LifeComponent
@onready var shake_component: ShakeComponent = $ShakeComponent

func _ready() -> void:
	life_component.died.connect(func() -> void:
		sprite.frame=(randi() % 3) + 1
	)

	life_component.damage_taken.connect(func(_dam: int, _dir: Vector2, _force: int) -> void:
		shake_component.shake(sprite)
		if life_component.hp == 0:
			#_spawn_wood_fragments(dir)
			if randi() % 7 == 0:
				var item_on_floor: ItemOnFloor=preload ("res://items/item_on_floor.tscn").instantiate()
				var food: Food=Food.new()
				room.add_item_on_floor(item_on_floor, position + Vector2(randf_range( - 8, 8), randf_range( - 8, 8)))
				item_on_floor.initialize(food)
				item_on_floor.enable_pick_up()
	)
