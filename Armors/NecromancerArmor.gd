extends Armor

const DRAIN_LIFE_PARTICLES_SCENE: PackedScene = preload("res://Shaders and Particles/DrainLifeParticles.tscn")

func _init() -> void:
	initialize("NECROMANCER", "NECROMANCER_ARMOR_DESCRIPTION", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_04.png"), 10, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_necromancer_icon.png"), 2, 2)


func enable_ability_effect(player: Player) -> void:
	var closer_enemy: Enemy = null
	var distance_to_closer_enemy: float = INF

	for enemy in player.get_tree().get_nodes_in_group("enemies"):
		if enemy.life_component.hp == 0:
			continue
		var distance_to_enemy: float = (player.position - enemy.global_position).length()
		if distance_to_enemy < distance_to_closer_enemy:
			closer_enemy = enemy
			distance_to_closer_enemy = distance_to_enemy

	if closer_enemy == null:
		return

	var drain_life_particles: DrainLifeParticles = DRAIN_LIFE_PARTICLES_SCENE.instantiate()
	player.get_tree().current_scene.add_child(drain_life_particles)
	drain_life_particles.start_draining(closer_enemy, player)


func disable_ability_effect(player: Player) -> void:
	pass
