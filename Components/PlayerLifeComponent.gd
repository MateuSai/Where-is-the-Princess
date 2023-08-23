class_name PlayerLifeComponent extends LifeComponent


@onready var player: Player = get_parent()


func take_damage(dam: int, dir: Vector2, force: int) -> void:
	if _must_ignore_damage():
		return

	if not player.armor is NoArmor:
		player.armor.condition -= dam * damage_taken_multiplier
		dam = 0
		if player.armor.condition <= 0:
			var particles: GPUParticles2D = load("res://Shaders and Particles/DestroyParticles.tscn").instantiate()
			particles.position += Vector2.UP * 6
			player.add_child(particles)
			player.set_armor(NoArmor.new())

	super(dam, dir, force)
