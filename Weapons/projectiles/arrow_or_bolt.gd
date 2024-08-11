class_name ArrowOrBolt extends Projectile

const WORLD_IMPACT_SOUNDS: Array[AudioStreamWAV] = [ preload ("res://Audio/Sounds/impact/521242__cyoung510__arrow_hits_target_1.wav"), preload ("res://Audio/Sounds/impact/521242__cyoung510__arrow_hits_target_2.wav"), preload ("res://Audio/Sounds/impact/521242__cyoung510__arrow_hits_target_3.wav")]
var textures: Array[Texture2D] = []
const MODIFIER_TEXTURES: Array[Texture] = [ preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/default_arrow_icon.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/homing_arrow_icon.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/piercing_arrow_icon.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/bouncing_arrow_icon.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/explosive_arrow_icon.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/icon_map.png")]

enum Type {
	NORMAL,
	HOMING,
	PIERCING,
	BOUNCING,
	EXPLOSIVE,
	UI,
}
var type: Type = Type.NORMAL: set = _set_type

func _ready() -> void:
	super()

@warning_ignore("shadowed_variable")
func launch(initial_position: Vector2, dir: Vector2, speed: int, rotate_to_dir: bool=false) -> void:
	super(initial_position, dir, speed, rotate_to_dir)

	var par: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
	par.collide_with_areas = false
	par.collide_with_bodies = true
	par.collision_mask = 1
	par.hit_from_inside = true
	par.to = initial_position
	par.from = damage_dealer.global_position if damage_dealer else initial_position - dir * sprite.get_rect().size.x
	var result: Dictionary = get_world_2d().direct_space_state.intersect_ray(par)
	if not result.is_empty():
		Log.debug("ArrowOrBolt collided at the start")
		_attach_projectile(result.collider)

func _collide(node: Node2D, dam: int=damage) -> void:
	collided_with_something.emit(node)

	if type == Type.EXPLOSIVE:
		var explosion: Explosion = (load("res://Weapons/projectiles/explosion.tscn") as PackedScene).instantiate()
		explosion.position = position
		await get_tree().process_frame
		get_tree().current_scene.add_child(explosion)
		destroy()
		return

	if node.get("life_component") != null:
		@warning_ignore("unsafe_property_access", "unsafe_method_access")
		node.life_component.take_damage(dam, knockback_direction, knockback_force, weapon if is_instance_valid(weapon) else null, damage_dealer, damage_dealer_id, true)
		if bodies_pierced >= piercing:
			_attach_projectile(node)
		else:
			bodies_pierced += 1
	else:
		if bounces_remaining > 0:
			bounces_remaining -= 1
			_bounce()
		else:
			_attach_projectile(node)

func _attach_projectile(body: Node2D) -> void:
	var sprite_clone: Sprite2D = $Sprite2D.duplicate()

	if body is Character:
		body.sprite.add_child(sprite_clone)
	else:
		var sound: AutoFreeSound = AutoFreeSound.new()
		get_tree().current_scene.add_child(sound)
		sound.start(WORLD_IMPACT_SOUNDS[randi() % WORLD_IMPACT_SOUNDS.size()], position, -5)
		get_tree().current_scene.add_child(sprite_clone)

	#sprite_clone.z_index = -1
	sprite_clone.rotation += rotation
	sprite_clone.global_position = position

	destroy()

func destroy() -> void:
	super()

func _set_type(new_type: Type) -> void:
	type = new_type
	sprite.texture = textures[type]
	match type:
		Type.NORMAL:
			pass
		Type.HOMING:
			var homing_component: HomingComponent = HOMING_COMPONENT_SCENE.instantiate()
			homing_component.homing_degree = 0.05
			add_child(homing_component)
		Type.PIERCING:
			piercing += 1
		Type.BOUNCING:
			bounces_remaining += 1
		Type.EXPLOSIVE:
			pass
		Type.UI:
			collision_shape.shape = null
			get_tree().create_timer(0.8).timeout.connect(destroy)
