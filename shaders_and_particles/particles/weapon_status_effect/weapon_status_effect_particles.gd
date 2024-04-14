class_name WeaponStatusEffectParticles extends GPUParticles2D

@onready var weapon_sprite: Sprite2D = get_parent()

@onready var particles_process_material: ParticleProcessMaterial = process_material

func _ready() -> void:
    particles_process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINTS
    particles_process_material.emission_point_texture = weapon_sprite.texture
    particles_process_material.emission_point_count = 200