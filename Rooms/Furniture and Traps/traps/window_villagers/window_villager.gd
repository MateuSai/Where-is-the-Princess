@tool

class_name WindowVillager extends Sprite2D

const POSSIBLE_PROJECTILES: Array[PackedScene] = [ preload ("res://Weapons/projectiles/small_rock/small_rock.tscn"), preload ("res://Weapons/projectiles/pottery/pottery.tscn"), preload ("res://Weapons/projectiles/cabbage/cabbage.tscn")]

const RANGE: int = 180
const PROJECTILE_SPEED: int = 120

@export var row: int = 0:
	set(new_row):
		row = new_row
		frame_coords.y = row

@onready var room: DungeonRoom = owner

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var throw_position: Marker2D = $ThrowPosition
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var house_shape_detector: Area2D = $HouseShapeDetector

func _ready() -> void:
	if Engine.is_editor_hint():
		frame_coords.x = 1

	house_shape_detector.body_shape_entered.connect(func(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
		#Log.debug()
		Log.debug(name + ": " + "   Body name: " + body.name + "  shape index: " + str(body_shape_index))
	)

	room.player_entered.connect(func() -> void:
		animation_player.animation_finished.connect(_on_animation_finished)
		cooldown_timer.timeout.connect(func() -> void:
			var dis: Vector2=Globals.player.global_position - throw_position.global_position
			if dis.y > 0 and dis.length() <= RANGE:
				animation_player.play("throw")
			else:
				cooldown_timer.start(randf_range(0.8, 3.0))
		)
		cooldown_timer.start(randf_range(2.0, 4.0))
	)
	room.cleared.connect(queue_free)

func _on_animation_finished(_anim_name: String) -> void:
	cooldown_timer.start(randf_range(0.8, 5.0))

func _throw() -> void:
	var dis: Vector2 = Globals.player.global_position - throw_position.global_position

	var projectile: Projectile = POSSIBLE_PROJECTILES[randi() % POSSIBLE_PROJECTILES.size()].instantiate()
	projectile.z_index += 1
	get_tree().current_scene.add_child(projectile)
	projectile.launch(throw_position.global_position, dis.normalized(), PROJECTILE_SPEED)

	var projectile_lifetime: Timer = Timer.new()
	projectile_lifetime.one_shot = true
	projectile.add_child(projectile_lifetime)
	projectile_lifetime.timeout.connect(projectile.destroy)
	projectile_lifetime.start(dis.length() / PROJECTILE_SPEED)
