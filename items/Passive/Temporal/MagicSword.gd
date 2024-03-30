class_name MagicSword extends TemporalPassiveItem


var magic_sword_node: MagicSwordNode

@export var hp: int = 5


func get_icon() -> Texture2D:
	return load("res://Art/items/orbital_sword_icon.png")


func get_big_icon() -> Texture2D:
	return load("res://Art/items/orbital_sword_UI_desc.png")


func equip(player: Player) -> void:
	magic_sword_node = MagicSwordNode.new()
	magic_sword_node.life_component.hp = hp
	magic_sword_node.hp_changed.connect(func(new_hp: int) -> void: hp = new_hp)
	magic_sword_node.destroyed.connect(func() -> void: player.unequip_passive_item(self))
	player.add_rotating_item(magic_sword_node)


func unequip(player: Player) -> void:
	var particles: GPUParticles2D = (load("res://shaders_and_particles/DestroyParticles.tscn") as PackedScene).instantiate()
	particles.position = magic_sword_node.sprite.global_position
	magic_sword_node.get_tree().current_scene.add_child(particles)
	player.remove_rotating_item(magic_sword_node)


class MagicSwordNode extends WeaponHitbox:
	var prev_rot: float = 0

	var sprite: Sprite2D
	var life_component: LifeComponent

	signal hp_changed(new_hp: int)
	signal destroyed()


	func _init() -> void:
		position.y = -2
		# Can't collide with worl
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		# Can collide with enemies and projectiles
		set_collision_mask_value(3, true)
		set_collision_mask_value(4, true)

		collided_with_something.connect(func(_body: Node2D) -> void:
			life_component.hp -= 1
		)

		sprite = Sprite2D.new()
		sprite.texture = load("res://Art/items/orbital sword.png")
		add_child(sprite)
		sprite.rotation += 3*PI/4
		sprite.position.y += 10

		var col: CollisionShape2D = CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(5, 18)
		col.shape = shape
		add_child(col)
		col.position.y += 10

		life_component = LifeComponent.new()
		life_component.name = "LifeComponent"
		life_component.max_hp = 5
		#life_component.hp = 2

		life_component.hp_changed.connect(func(new_hp: int) -> void: hp_changed.emit(new_hp))
		life_component.died.connect(func() -> void: destroyed.emit())
		add_child(life_component)


	func _physics_process(delta: float) -> void:
		prev_rot = rotation
		rotation = wrapf(rotation - 3 * delta, 0, 2*PI)
		#print(rotation)
		if rotation < 3*PI/2 and prev_rot > 3*PI/2:
			get_parent().move_child(self, 0)
		elif rotation < PI/2 and prev_rot > PI/2:
			get_parent().move_child(self, get_parent().get_child_count()-1)

#		sprite.global_rotation = 0
#		sprite.frame = floor(((2*PI - rotation) / (2*PI)) * sprite.hframes)


	#func _on_collided_with_something()
