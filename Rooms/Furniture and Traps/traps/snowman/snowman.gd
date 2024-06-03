class_name Snowman extends StaticBody2D

const SNOW_PILE_TEXTURES: Array[Texture2D] = [ preload ("res://Art/16x16 Pixel Art Roguelike (Village) Pack/Enemies/Snowmen/Snowmen_pile_01.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Village) Pack/Enemies/Snowmen/Snowmen_pile_02.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Village) Pack/Enemies/Snowmen/Snowmen_pile_03.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Village) Pack/Enemies/Snowmen/Snowmen_pile_04.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Village) Pack/Enemies/Snowmen/Snowmen_pile_05.png")]

var is_thief_inside: bool = randi() % 2

@onready var room: DungeonRoom = owner

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var player_detector: Area2D = $PlayerDetector
@onready var life_component: LifeComponent = $LifeComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	sprite.frame_coords.y = randi() % sprite.vframes
	sprite.flip_h = randi() % 2

	if not is_thief_inside:
		player_detector.queue_free()
		life_component.died.connect(destroy)
	else:
		life_component.max_hp = Enemy.get_data("thief").max_hp
		life_component.hp = Enemy.get_data("thief").max_hp
		life_component.damage_taken.connect(func(dam: int, dir: Vector2, force: int) -> void:
			if Enemy.get_data("thief").max_hp <= dam:
				destroy()
			else:
				Log.debug(dir)
				life_component.take_damage(2000, dir, force, null, null, "")
				destroy()
				var thief: Thief=_spawn_thief()
				await get_tree().process_frame
				thief.life_component.hp -= dam
		, CONNECT_ONE_SHOT)

		player_detector.body_entered.connect(func(body: Node2D) -> void:
			assert(body is Player)
			life_component.take_damage(2000, Vector2.ZERO, 0, null, null, "")
			destroy()
			_spawn_thief()
		)

		await get_tree().create_timer(randf_range(0.0, 3.5), false).timeout
		animation_player.play("breath")

func _spawn_thief() -> Thief:
	var thief: Enemy = Globals.get_enemy_scene("thief").instantiate()
	thief.position = position
	room.call_deferred("add_enemy", thief)
	return thief

func destroy() -> void:
	sprite.frame_coords = Vector2.ZERO
	sprite.hframes = 1
	sprite.vframes = 1
	sprite.texture = SNOW_PILE_TEXTURES[randi() % SNOW_PILE_TEXTURES.size()]
	collision_shape.queue_free()
	$HurtBox.queue_free()
	life_component.queue_free()
	if is_instance_valid(player_detector):
		player_detector.queue_free()
	animation_player.queue_free()