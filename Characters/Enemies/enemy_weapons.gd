class_name EnemyWeapons extends Node2D

var attack_cooldown_timer: Timer

@onready var current_weapon: Weapon = get_child(0)


func _ready() -> void:
#	super()

	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.wait_time = 0.75
	add_child(attack_cooldown_timer)


func move(mouse_direction: Vector2) -> void:
#	if disabled:
#		return

	var prev_current_weap_rot: float = current_weapon.rotation
	current_weapon.move(mouse_direction)
	#if (prev_current_weap_rot > 0 and current_weapon.rotation < 0) or (prev_current_weap_rot < 0 and current_weapon.rotation > 0):
	if prev_current_weap_rot < 0 and current_weapon.rotation > 0:
		get_parent().move_child(self, -1)
	elif prev_current_weap_rot > 0 and current_weapon.rotation < 0:
		get_parent().move_child(self, 0)


func is_busy() -> bool:
	return current_weapon.is_busy() or not attack_cooldown_timer.is_stopped()


func attack() -> void:
	assert(not is_busy())

	current_weapon._attack()

	attack_cooldown_timer.start()
