@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/boss_druid/druid_scepter.png")
class_name Scepter extends RangedWeapon


#@onready var pivot_2: Node2D = $Pivot/Pivot2


func _ready() -> void:
	super()

	animation_library = "scepter_animation_library"


func move(mouse_direction: Vector2) -> void:
	super(mouse_direction)

	if mouse_direction.x >= 0:
		#pivot_2.scale.x = 1
		weapon_sprite.scale.y = 1
		#pivot_2.rotation = 0
	else:
		#pivot_2.scale.x = -1
		weapon_sprite.scale.y = -1
		#pivot_2.rotation = PI/2


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack") and not animation_player.is_playing():
		_charge()
	elif event.is_action_released("ui_attack"):
		#var complete_current_animation: PackedStringArray = animation_player.current_animation.split("/")
		#var current_animation: String = complete_current_animation[complete_current_animation.size() - 1]
		if animation_player.is_playing() and get_current_animation().begins_with("charge") and weapon_sprite.material.get("shader_parameter/active"):
			_bow_attack(animation_player.current_animation_position / animation_player.current_animation_length)
		#elif weapon_sprite.frame > 0:
			#_bow_attack(1.0)
		else:
			animation_player.play("RESET")

	if event.is_action_pressed("ui_weapon_ability") and has_active_ability() and not is_busy() and can_active_ability():
		_active_ability()


## Charge has a value between 0 and 1 where 1 is max charged
func _bow_attack(charge: float) -> void:
	projectile_speed = int(80 + 230 * charge) # The speed is truncated, a difference of 1 is very small anyway

	if is_equal_approx(charge, 1.0):
		damage += 2
	elif charge > 0.6:
		damage += 1

	_attack()

	assert(get_current_animation().begins_with("attack"))
	await animation_player.animation_finished # We wait until attack animation is finished

	if is_equal_approx(charge, 1.0):
		damage -= 2
	elif charge > 0.6:
		damage -= 1


func _spawn_projectile(angle: float = 0.0, amount: int = 1) -> Array[Projectile]:
	#staff_animation_player.play("lighting_attack")
	#await staff_animation_player.animation_finished
	#if staff_animation_player.assigned_animation == "RESET": # this means we cancelled the attack
		#return
	#can_move = false

	var lightning: LightningAreaAttack = load("res://Characters/Enemies/BodenTheDruid/LightningAreaAttack.tscn").instantiate()
	lightning.position = global_position
	get_tree().current_scene.add_child(lightning)
	lightning.attack(Vector2.RIGHT.rotated(rotation))
	Globals.player.camera.flash()
#	var lightning_line: LightningLine2D = LightningLine2D.new()
#	get_tree().current_scene.add_child(lightning_line)
#	lightning_line.lightning(player.position, global_position)
	#await lightning.tree_exiting

	#if is_instance_valid(staff):
	#if is_instance_valid(staff_animation_player):
		#staff_animation_player.play("after_lightning_attack")
		#await staff_animation_player.animation_finished
	#can_move = true

	return []
