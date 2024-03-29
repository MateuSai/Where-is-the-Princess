class_name PlayerAttackingRepresentation extends Control

var weapon: Weapon

var pre_attack_cooldown_timer: Timer
var attack_cooldown_timer: Timer

@onready var player_sprite: Sprite2D = $PlayerRepresentation/PlayerSprite
@onready var weapons: Node2D = $PlayerRepresentation/Weapons


func initialize(weapon_path: String) -> void:
	pre_attack_cooldown_timer = Timer.new()
	pre_attack_cooldown_timer.one_shot = true
	pre_attack_cooldown_timer.wait_time = 0.3
	pre_attack_cooldown_timer.timeout.connect(_actually_attack)
	add_child(pre_attack_cooldown_timer)

	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.wait_time = 0.75
	add_child(attack_cooldown_timer)

	player_sprite.texture = Globals.player.sprite.texture
	weapon = load(weapon_path).instantiate()
	weapon.rotation = +PI/5
	weapons.add_child(weapon)
	weapon.data.condition_cost_per_normal_attack = 0.0


func _process(delta: float) -> void:
	if not is_busy():
		attack()


func is_busy() -> bool:
	return weapon.is_busy() or not attack_cooldown_timer.is_stopped() or not pre_attack_cooldown_timer.is_stopped()


func attack() -> void:
	assert(not is_busy())

	pre_attack_cooldown_timer.start()


func reload() -> void:
	assert(weapon is Crossbow)
	assert(not is_busy())

	weapon._reload()


func _actually_attack() -> void:
	weapon._attack()

	attack_cooldown_timer.start()
