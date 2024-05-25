class_name Snowman extends StaticBody2D

var is_thief_inside: bool = randi() % 2

@onready var room: DungeonRoom = owner

@onready var sprite: Sprite2D = $Sprite2D
@onready var player_detector: Area2D = $PlayerDetector
@onready var life_component: LifeComponent = $LifeComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	sprite.frame_coords.y = randi() % sprite.vframes
	sprite.flip_h = randi() % 2

	if not is_thief_inside:
		player_detector.queue_free()
	else:
		life_component.damage_taken.connect(func(dam: int, _dir: Vector2, _force: int) -> void:
			if Enemy.get_data("thief").max_hp <= dam:
				queue_free()
			else:
				var thief: Thief=_spawn_thief()
				await get_tree().process_frame
				thief.life_component.hp -= dam
				queue_free()
		)

		player_detector.body_entered.connect(func(body: Node2D) -> void:
			assert(body is Player)
			_spawn_thief()
			queue_free()
		)

		await get_tree().create_timer(randf_range(0.0, 3.0), false).timeout
		animation_player.play("breath")

func _spawn_thief() -> Thief:
	var thief: Enemy = Globals.get_enemy_scene("thief").instantiate()
	thief.position = position
	room.call_deferred("add_enemy", thief)
	return thief