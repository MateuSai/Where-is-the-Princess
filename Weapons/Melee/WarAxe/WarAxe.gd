extends MeleeWeapon

var throwed_using_active_ability: bool
var active_ability_dir_weight: float = 0.005

@onready var initial_throw_speed: int = throw_speed

@onready var trail_animation_player: AnimationPlayer = $Node2D/WeaponSprite/TrailSpriteAnimationPlayer


func _physics_process(delta: float) -> void:
	if throwed_using_active_ability:
		active_ability_dir_weight = clamp(active_ability_dir_weight + 0.025 * delta, 0, 0.02)
		throw_dir = throw_dir.lerp((Globals.player.position - global_position).normalized(), active_ability_dir_weight)

	super(delta)


func _throw_using_active_ability(dir: int) -> void:
	throw_speed = initial_throw_speed * 2
	throw_rot_speed = dir * 50
	throwed_using_active_ability = true
	trail_animation_player.animation_finished.connect(_on_trail_animation_ended)
	trail_animation_player.play("appear")
	throw()
	piercing = 200


func _on_trail_animation_ended(anim_name: String) -> void:
	assert(anim_name == "appear")
	trail_animation_player.animation_finished.disconnect(_on_trail_animation_ended)
	trail_animation_player.play("on_air")
	hitbox.set_collision_mask_value(2, true) # So it can detect collisions with player


#func _on_animation_finished(_anim_name: String) -> void:
	#pass


func _throw_body_entered_hitbox(body: Node2D) -> void:
	if hitbox._get_entity(body) is Player:
		_go_back_to_before_throw_state()
		_on_PlayerDetector_body_entered(hitbox._get_entity(body)) # Pick up the weapon
	else:
		super(body)


func _go_back_to_before_throw_state() -> void:
	super()

	if throwed_using_active_ability:
		throw_speed = initial_throw_speed

		hitbox.set_collision_mask_value(2, false) # So it can't detect collisions with player
		trail_animation_player.play_backwards("appear")
		throwed_using_active_ability = false
		await trail_animation_player.animation_finished
		$Node2D/WeaponSprite/TrailSprite.hide()

		_decrease_weapon_condition(active_ability_condition_cost)
#		stats.set_condition(stats.condition - active_ability_condition_cost)
