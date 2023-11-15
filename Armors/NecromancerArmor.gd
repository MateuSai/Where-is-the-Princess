extends Armor

const DRAIN_LIFE_PARTICLES_SCENE: PackedScene = preload("res://shaders_and_particles/DrainLifeParticles.tscn")

func _init() -> void:
	initialize(10, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_necromancer_icon.png"), 2, 2)


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


func disable_ability_effect(_player: Player) -> void:
	pass


func get_sprite_sheet() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_04.png")


func get_icon() -> Texture:
	return Globals.get_atlas_frame(load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png"), Rect2(0, 32, 16, 16))
