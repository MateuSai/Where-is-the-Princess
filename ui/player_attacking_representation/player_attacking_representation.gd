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
	#weapon.rotation = +PI/24
	weapons.add_child(weapon)
	weapon.data.condition_cost_per_normal_attack = 0.0
	weapon.data.active_ability_condition_cost = 0.0
	weapon.data.souls_to_activate_ability = 0

	if weapon is BowOrCrossbowWeapon:
		(weapon as BowOrCrossbowWeapon).arrow_type = ArrowOrBolt.Type.UI
		
	if weapon is Bow:
		var bow: Bow = weapon
		bow.projectiles_spawned.connect(func(projectiles: Array[Projectile]) -> void:
			for projectile: Projectile in projectiles:
				projectile.get_parent().remove_child(projectile)
				projectile.position -= global_position
				add_child(projectile)
				#projectile.launch((weapon as Bow).spawn_projectile_pos.global_position)
		)
		#var bow: Bow = weapon
		#bow.projectiles_spawned.connect(func(projectiles: Array[Projectile]) -> void:
			#for projectile in projectiles:
				#projectile.queue_free()
		#)
	elif weapon is Crossbow:
		var crossbow: Crossbow = weapon
		crossbow.projectiles_spawned.connect(func(projectiles: Array[Projectile]) -> void:
			for projectile: Projectile in projectiles:
				projectile.get_parent().remove_child(projectile)
				projectile.position -= global_position
				add_child(projectile)
		)

	draw.connect(func() -> void:
		set_process(true)
	)
	hidden.connect(func() -> void:
		set_process(false)
	)

func _process(_delta: float) -> void:
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
	if weapon is MeleeWeapon:
		weapon._attack()
	elif weapon is Bow:
		var bow: Bow = weapon
		bow._charge()
		bow.animation_player.animation_finished.connect(_on_bow_animation_finished)
	elif weapon is Crossbow:
		var crossbow: Crossbow = weapon
		reload()
		crossbow.animation_player.animation_finished.connect(_on_crossbow_animation_finished)
	else:
		push_error("Unsupoorted weapon attack")

	attack_cooldown_timer.start()

func _on_bow_animation_finished(_anim_name: String) -> void:
	(weapon as Bow)._bow_attack(1.0)
	weapon.animation_player.animation_finished.disconnect(_on_bow_animation_finished)

func _on_crossbow_animation_finished(_anim_name: String) -> void:
	await get_tree().create_timer(0.8).timeout
	(weapon as Crossbow)._attack()
	weapon.animation_player.animation_finished.disconnect(_on_crossbow_animation_finished)