class_name PlayerLifeComponent extends LifeComponent

@onready var player: Player = get_parent()
@onready var hit_border_effect: HitBorderEffect = $"../UI/HitBorderEffect"

func take_damage(dam: int, dir: Vector2, force: int, weapon: Weapon, damage_dealer: Node, damage_dealer_id: String, is_ranged: bool=false) -> void:
	if _must_ignore_damage():
		return

	dam = dam * damage_taken_multiplier + extra_damage_taken + _get_extra_damage_by_enemy_id(damage_dealer_id)

	if player.armor is Underpants: # We decrease hp
		hit_border_effect.effect(hit_border_effect.Type.HP, invincible_after_being_hitted_time)
		self.hp -= dam
		_play_hit_sound(weapon)
	else: # we decrease armor condition
		player.armor.condition -= dam * damage_taken_multiplier
		hit_border_effect.effect(hit_border_effect.Type.ARMOR, invincible_after_being_hitted_time)
		#dam = 0
		if player.armor.condition <= 0:
			for fragment_texture: Texture2D in Armor.get_fragments_by_path((player.armor.get_script() as Script).get_path()):
				var fragment: WeaponFragment = load("res://effects/fragments/weapon_fragment.tscn").instantiate()
				fragment.position = player.global_position
				get_tree().current_scene.add_child(fragment)
				fragment.throw(player, Vector2.ZERO, fragment_texture)
			
			var particles: GPUParticles2D = load("res://shaders_and_particles/particles/DestroyParticles.tscn").instantiate()
			particles.position += Vector2.UP * 6
			player.add_child(particles)
			player.set_armor(Underpants.new())

	last_weapon = weapon
	last_damage_dealer_id = damage_dealer_id
	last_is_ranged = is_ranged
	damage_taken.emit(dam, dir, force)

	invincible_after_being_hitted = true
	invincible_after_being_hitted_timer.start(invincible_after_being_hitted_time)

	if not is_ranged and damage_dealer and damage_dealer.has_node("LifeComponent") and thorn_damage:
		_apply_thorn_damage(damage_dealer)

func take_damage_ignoring_armor(dam: int, dir: Vector2, force: int, weapon: Weapon, damage_dealer: Node, damage_dealer_id: String, is_ranged: bool=false) -> void:
	if _must_ignore_damage():
		return

	dam = dam * damage_taken_multiplier + extra_damage_taken + _get_extra_damage_by_enemy_id(damage_dealer_id)

	hit_border_effect.effect(hit_border_effect.Type.HP, invincible_after_being_hitted_time)
	self.hp -= dam
	_play_hit_sound(weapon)

	damage_taken.emit(dam, dir, force)
	last_damage_dealer_id = damage_dealer_id

	invincible_after_being_hitted = true
	invincible_after_being_hitted_timer.start(invincible_after_being_hitted_time)

	if not is_ranged and damage_dealer and damage_dealer.has_node("LifeComponent") and thorn_damage:
		_apply_thorn_damage(damage_dealer)
