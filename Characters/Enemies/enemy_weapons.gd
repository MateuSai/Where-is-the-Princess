class_name EnemyWeapons extends Weapons

var pre_attack_cooldown_timer: Timer
var attack_cooldown_timer: Timer


func _ready() -> void:
#	super()

	current_weapon = get_child(0)

	pre_attack_cooldown_timer = Timer.new()
	pre_attack_cooldown_timer.one_shot = true
	pre_attack_cooldown_timer.wait_time = 0.3
	pre_attack_cooldown_timer.timeout.connect(_actually_attack)
	add_child(pre_attack_cooldown_timer)

	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.wait_time = 0.75
	add_child(attack_cooldown_timer)


func is_busy() -> bool:
	return current_weapon.is_busy() or not attack_cooldown_timer.is_stopped() or not pre_attack_cooldown_timer.is_stopped()


func attack() -> void:
	assert(not is_busy())

	pre_attack_cooldown_timer.start()


func _actually_attack() -> void:
	current_weapon._attack()

	attack_cooldown_timer.start()
