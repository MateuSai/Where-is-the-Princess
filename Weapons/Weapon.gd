@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/heroes/knight/weapon_sword_1.png")
class_name Weapon extends Node2D

@export var on_floor: bool = false

@export var condition_degrade_by_attack: float = 34

var can_active_ability: bool = true

var stats: WeaponStats = null

signal condition_changed(weapon: Weapon, new_condition: float)

var tween: Tween = null
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var hitbox: WeaponHitbox = get_node("Node2D/Sprite2D/Hitbox")
@onready var charge_particles: GPUParticles2D = get_node("Node2D/Sprite2D/ChargeParticles")
@onready var weapon_sprite: Sprite2D = get_node("Node2D/Sprite2D")
@onready var player_detector: Area2D = weapon_sprite.get_node("PlayerDetector")
@onready var cool_down_timer: Timer = get_node("CoolDownTimer")
@onready var ui: CanvasLayer = get_node("UI")
@onready var ability_icon: TextureProgressBar = ui.get_node("AbilityIcon")


func _ready() -> void:
	if not on_floor:
		player_detector.set_collision_mask_value(1, false)
		player_detector.set_collision_mask_value(2, false)

	if stats == null:
		stats = WeaponStats.new(scene_file_path)

	stats.connect("condition_changed", _on_condition_changed)

	connect("draw", _on_show)
	connect("hidden", _on_hide)


func get_input() -> void:
	if Input.is_action_just_pressed("ui_attack") and not animation_player.is_playing():
		_charge()
	elif Input.is_action_just_released("ui_attack"):
		if animation_player.is_playing() and animation_player.current_animation.begins_with("charge"):
			attack()
		elif charge_particles.emitting:
			_strong_attack()
	elif Input.is_action_just_pressed("ui_active_ability") and animation_player.has_animation("active_ability") and not is_busy() and can_active_ability:
		can_active_ability = false
		cool_down_timer.start()
		ui.recharge_ability_animation(cool_down_timer.wait_time)
		animation_player.play("active_ability")


func move(mouse_direction: Vector2) -> void:
	#if not animation_player.is_playing() or animation_player.current_animation == "charge":
	rotation = mouse_direction.angle()
	hitbox.knockback_direction = mouse_direction
	if scale.y == 1 and mouse_direction.x < 0:
		scale.y = -1
	elif scale.y == -1 and mouse_direction.x > 0:
		scale.y = 1


func attack() -> void:
	animation_player.play("attack")


func _strong_attack() -> void:
	animation_player.play("strong_attack")


func _charge() -> void:
	animation_player.play("charge")


func cancel_attack() -> void:
	animation_player.play("RESET")


func is_busy() -> bool:
	return animation_player.is_playing() or charge_particles.emitting


func _on_PlayerDetector_body_entered(body: Node2D) -> void:
	if body is Player:
		body.weapons.pick_up_weapon(self)
		_pick_up()
	else:
		if tween:
			tween.kill()
		player_detector.set_collision_mask_value(2, true)


func _pick_up() -> void:
	player_detector.set_collision_mask_value(1, false)
	player_detector.set_collision_mask_value(2, false)
	animation_player.play("RESET")
	position = Vector2.ZERO


func interpolate_pos(initial_pos: Vector2, final_pos: Vector2) -> void:
	position = initial_pos
	tween = create_tween()
	tween.tween_property(self, "position", final_pos, 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.connect("finished", _on_Tween_tween_completed)
	player_detector.set_collision_mask_value(1, true)


func _on_Tween_tween_completed() -> void:
	player_detector.set_collision_mask_value(2, true)


func _on_CoolDownTimer_timeout() -> void:
	can_active_ability = true


func _on_condition_changed(new_condition: float) -> void:
	if get_parent() is Weapons:
		emit_signal("condition_changed", self, new_condition)
	else:
		if new_condition <= 0:
			destroy()


func destroy() -> void:
	animation_player.stop(true)

	player_detector.queue_free()
	hitbox.queue_free()

	# Shader culiada, tengo que quitar el offset del sprite para que funcione bien
	weapon_sprite.position += weapon_sprite.offset
	weapon_sprite.offset = Vector2.ZERO
	var particles: GPUParticles2D = load("res://Shaders and Particles/DestroyParticles.tscn").instantiate()
	particles.position = weapon_sprite.global_position
	get_tree().current_scene.add_child(particles)
	weapon_sprite.material = ResourceLoader.load("res://Shaders and Particles/PixelExplosionMaterial.tres", "ShaderMaterial", ResourceLoader.CACHE_MODE_IGNORE)
	#weapon_sprite.material.resource_local_to_scene = true
	#weapon_sprite.material.set("shader_parameter/progress", 0)
	await create_tween().tween_property(weapon_sprite.material, "shader_parameter/progress", 1, 10).finished
	#await get_tree().create_timer(1).timeout
	queue_free()


func _on_show() -> void:
	ability_icon.show()


func _on_hide() -> void:
	ability_icon.hide()


func get_texture() -> Texture2D:
	return get_node("Node2D/Sprite2D").texture
