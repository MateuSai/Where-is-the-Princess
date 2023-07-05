class_name MagicShield extends PassiveItem


func _init() -> void:
	_initialize(load("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/bomb_anim_f0.png"))


func equip(player: Player) -> void:
	player.add_child(MagicShieldNode.new())


func unequip(_player: Player) -> void:
	pass


class MagicShieldNode extends StaticBody2D:
	var prev_rot: float = 0

	func _init() -> void:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = load("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/bomb_anim_f0.png")
		add_child(sprite)
		sprite.position.y += 8

		var col: CollisionShape2D = CollisionShape2D.new()
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(50, 2)
		col.shape = shape
		add_child(col)
		col.position.y += 8


	func _physics_process(delta: float) -> void:
		prev_rot = rotation
		rotation = wrapf(rotation + 5 * delta, 0, 2*PI)
		if rotation > PI/2 and prev_rot < PI/2:
			get_parent().move_child(self, 0)
		elif rotation > PI/4 and prev_rot < PI/4:
			get_parent().move_child(self, get_parent().get_child_count()-1)
