class_name EnemyWeapons extends Weapons

var attack_cooldown_timer: Timer


func _ready() -> void:
#	super()

	current_weapon = get_child(0)

	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.wait_time = 0.75
	add_child(attack_cooldown_timer)


func is_busy() -> bool:
	return current_weapon.is_busy() or not attack_cooldown_timer.is_stopped()


func attack() -> void:
	assert(not is_busy())

	current_weapon._attack()

	attack_cooldown_timer.start()
