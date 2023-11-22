class_name BodenTheDruid extends Enemy

const BIRD_SCENE: PackedScene = preload("res://Weapons/projectiles/Bird.tscn")

const BEAR_HP: int = 25

var is_bear: bool = false

@onready var staff_pivot: Node2D = $StaffPivot
@onready var staff_pivot_2: Node2D = $StaffPivot/StaffPivot2
@onready var staff: Sprite2D = $StaffPivot/StaffPivot2/Staff
@onready var staff_animation_player: AnimationPlayer = $StaffPivot/StaffPivot2/Staff/AnimationPlayer
@onready var staff_end: Marker2D = $StaffPivot/StaffPivot2/Staff/StaffEnd
@onready var bird_attack_timer: Timer = $BirdAttackTimer
@onready var lightning_attack_timer: Timer = $LightningAttackTimer
@onready var rock_sprite: Sprite2D = $RockContainer/Rock
@onready var rock_container: Node2D = $RockContainer


func _ready() -> void:
	super()
	bird_attack_timer.timeout.connect(func():
		_bird_attack()
		bird_attack_timer.start(randf_range(2, 3))
	)

	lightning_attack_timer.timeout.connect(func():
		_lightning_attack()
		lightning_attack_timer.start(randf_range(2.5, 3.5))
	)


func _on_died() -> void:
	if not is_bear:
		_transform()
	else:
		super()


func _transform() -> void:
	is_bear = true
	life_component.max_hp = BEAR_HP
	life_component.hp = BEAR_HP
	name = "BodenTheBear"
	$BossHpBar.name_label.text = name
	state_machine.set_state(BodenTheDruidFSM.TRANSFORM)


func move_staff() -> void:
	if can_move:
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


func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - player.position).normalized()
	navigation_agent.target_position = global_position + dir * 100


func _on_change_dir() -> void:
	super()
	rock_container.scale.x *= -1


func _lightning_attack() -> void:
	staff_animation_player.play("lighting_attack")
	await staff_animation_player.animation_finished
	if staff_animation_player.assigned_animation == "RESET": # this means we cancelled the attack
		return
	can_move = false

	var lightning: LightningAreaAttack = load("res://Characters/Enemies/BodenTheDruid/LightningAreaAttack.tscn").instantiate()
	lightning.position = global_position
	get_tree().current_scene.add_child(lightning)
	lightning.attack(Vector2.RIGHT.rotated(staff_pivot.rotation))
	player.camera.flash()
#	var lightning_line: LightningLine2D = LightningLine2D.new()
#	get_tree().current_scene.add_child(lightning_line)
#	lightning_line.lightning(player.position, global_position)
	await lightning.tree_exiting

	#if is_instance_valid(staff):
	if is_instance_valid(staff_animation_player):
		staff_animation_player.play("after_lightning_attack")
		await staff_animation_player.animation_finished
	can_move = true


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


func interrupt_lightning_attack() -> void:
	if is_instance_valid(staff):
		staff_animation_player.stop()
		staff_animation_player.play("RESET")
		lightning_attack_timer.start(randf_range(2.5, 3.5))


func throw_rock() -> void:
	var rock: Projectile = load("res://Weapons/projectiles/BigRock.tscn").instantiate()
	rock.exclude = [self]
	get_tree().current_scene.add_child(rock)
	rock.launch(rock_sprite.global_position + Vector2.DOWN * 33, state_machine.rock_dir.rotated(randf_range(-0.4, 0.4)), 250)
	for child in rock.get_children():
		if child is Node2D:
			child.position += Vector2.UP * 33
