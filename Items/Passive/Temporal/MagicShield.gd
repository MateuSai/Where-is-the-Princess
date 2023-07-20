class_name MagicShield extends TemporalPassiveItem

var magic_shield_node: MagicShieldNode

@export var hp: int = 2


func get_icon() -> Texture:
	return load("res://Art/items/ShieldAnimation.tres")


#func _init() -> void:
#	_initialize(load("res://Art/items/ShieldAnimation.tres"))


func equip(player: Player) -> void:
	magic_shield_node = MagicShieldNode.new()
	magic_shield_node.life_component.hp = hp
	magic_shield_node.hp_changed.connect(func(new_hp: int): hp = new_hp)
	magic_shield_node.destroyed.connect(func(): player.unequip_passive_item(self))
	player.add_child(magic_shield_node)


func unequip(_player: Player) -> void:
	var particles: GPUParticles2D = load("res://Shaders and Particles/DestroyParticles.tscn").instantiate()
	particles.position = magic_shield_node.sprite.global_position
	magic_shield_node.get_tree().current_scene.add_child(particles)
	magic_shield_node.queue_free()


class MagicShieldNode extends StaticBody2D:
	var prev_rot: float = 0

	var sprite: Sprite2D
	var life_component: LifeComponent

	signal hp_changed(new_hp: int)
	signal destroyed()

	func _init() -> void:
		position.y = -2
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		set_collision_layer_value(2, true)

		sprite = Sprite2D.new()
		sprite.texture = load("res://Art/items/shield_rotating_player.png")
		sprite.hframes = 8
		add_child(sprite)
		sprite.position.y += 6

		var col: CollisionShape2D = CollisionShape2D.new()
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(50, 2)
		col.shape = shape
		add_child(col)
		col.position.y += 6

		life_component = LifeComponent.new()
		life_component.name = "LifeComponent"
		life_component.max_hp = 2
		#life_component.hp = 2

		life_component.hp_changed.connect(func(new_hp: int): hp_changed.emit(new_hp))
		life_component.died.connect(func(): destroyed.emit())
		add_child(life_component)


	func _physics_process(delta: float) -> void:
		prev_rot = rotation
		rotation = wrapf(rotation - 3 * delta, 0, 2*PI)
		#print(rotation)
		if rotation < 3*PI/2 and prev_rot > 3*PI/2:
			get_parent().move_child(self, 0)
		elif rotation < PI/2 and prev_rot > PI/2:
			get_parent().move_child(self, get_parent().get_child_count()-1)

		sprite.global_rotation = 0
		sprite.frame = floor(((2*PI - rotation) / (2*PI)) * sprite.hframes)
