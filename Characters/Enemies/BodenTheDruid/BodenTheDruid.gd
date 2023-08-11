class_name BodenTheDruid extends Enemy

const BIRD_SCENE: PackedScene = preload("res://Weapons/Projectiles/Bird.tscn")

const MAX_DISTANCE_TO_PLAYER: int = 90
const MIN_DISTANCE_TO_PLAYER: int = 45

var distance_to_player: float

@onready var staff_pivot: Node2D = $StaffPivot
@onready var staff_pivot_2: Node2D = $StaffPivot/StaffPivot2
@onready var staff: Sprite2D = $StaffPivot/StaffPivot2/Staff
@onready var staff_animation_player: AnimationPlayer = $StaffPivot/StaffPivot2/Staff/AnimationPlayer
@onready var staff_end: Marker2D = $StaffPivot/StaffPivot2/Staff/StaffEnd
@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
	super()
	attack_timer.timeout.connect(func():
		can_move = false
		if randi() % 3 == 0:
			await _lightning_attack()
		else:
			_bird_attack()
		attack_timer.start(randf_range(1.5, 2.5))
		can_move = true
		#_lightning_attack()
	)


func _process(_delta: float) -> void:
	var vector_to_player: Vector2 = player.position - global_position
	staff_pivot.rotation = lerp_angle(staff_pivot.rotation, vector_to_player.angle(), 0.05)
	if Vector2.RIGHT.rotated(staff_pivot.rotation).x > 0:
		staff_pivot_2.scale.x = 1
		staff.scale.x = 1
		staff_pivot_2.rotation = 0
	else:
		staff_pivot_2.scale.x = -1
		staff.scale.x = -1
		staff_pivot_2.rotation = PI/2


func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		distance_to_player = (player.position - global_position).length()
		if distance_to_player > MAX_DISTANCE_TO_PLAYER:
			_get_path_to_player()
		elif distance_to_player < MIN_DISTANCE_TO_PLAYER:
			_get_path_to_move_away_from_player()
		else:
			pass
#			aim_raycast.target_position = player.position - global_position
#			if can_attack and state_machine.state == state_machine.states.idle and not aim_raycast.is_colliding():
#				can_attack = false
#				_throw_knife()
#				attack_timer.start()
	else:
		mov_direction = Vector2.ZERO


func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - player.position).normalized()
	navigation_agent.target_position = global_position + dir * 100


func _lightning_attack() -> void:
	staff_animation_player.play("lighting_attack")
	await staff_animation_player.animation_finished

	var lightning: LightningAreaAttack = load("res://Characters/Enemies/BodenTheDruid/LightningAreaAttack.tscn").instantiate()
	staff_end.add_child(lightning)
	lightning.attack(Vector2.RIGHT.rotated(staff_pivot.rotation))
	player.camera.flash()
#	var lightning_line: LightningLine2D = LightningLine2D.new()
#	get_tree().current_scene.add_child(lightning_line)
#	lightning_line.lightning(player.position, global_position)
	await lightning.tree_exiting

	staff_animation_player.play("after_lightning_attack")
	await staff_animation_player.animation_finished


func _bird_attack() -> void:
	for i in randi_range(5, 8):
		var bird: Bird = BIRD_SCENE.instantiate()
		var bird_pos: Vector2 = player.position + Vector2(randf_range(110, 150), 0).rotated(randf_range(0, 2*PI))
		get_tree().current_scene.add_child(bird)

		var spawn_effect: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
		#spawn_effect.z_index = 10
		spawn_effect.position = bird_pos
		get_tree().current_scene.add_child(spawn_effect)

		bird.launch(bird_pos, (player.position - bird_pos).normalized(), 50)
