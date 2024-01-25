class_name PlayerLifeComponent extends LifeComponent


@onready var player: Player = get_parent()
@onready var hit_border_effect: HitBorderEffect = $"../UI/HitBorderEffect"


func take_damage(dam: int, dir: Vector2, force: int, weapon: Weapon) -> void:
	if _must_ignore_damage():
		return

	dam *= damage_taken_multiplier

	if player.armor is Underpants: # We decrease hp
		hit_border_effect.effect(hit_border_effect.Type.HP, invincible_after_being_hitted_time)
		self.hp -= dam
		_play_hit_sound(weapon)
	else: # we decrease armor condition
		player.armor.condition -= dam * damage_taken_multiplier
		hit_border_effect.effect(hit_border_effect.Type.ARMOR, invincible_after_being_hitted_time)
		#dam = 0
		if player.armor.condition <= 0:
			var particles: GPUParticles2D = load("res://shaders_and_particles/DestroyParticles.tscn").instantiate()
			particles.position += Vector2.UP * 6
			player.add_child(particles)
			player.set_armor(Underpants.new())

	damage_taken.emit(dam, dir, force)

	invincible_after_being_hitted = true
	invincible_after_being_hitted_timer.start(invincible_after_being_hitted_time)



func take_damage_ignoring_armor(dam: int, dir: Vector2, force: int, weapon: Weapon) -> void:
	if _must_ignore_damage():
		return

	dam *= damage_taken_multiplier

	hit_border_effect.effect(hit_border_effect.Type.HP, invincible_after_being_hitted_time)
	self.hp -= dam
	_play_hit_sound(weapon)

	damage_taken.emit(dam, dir, force)

	invincible_after_being_hitted = true
	invincible_after_being_hitted_timer.start(invincible_after_being_hitted_time)
