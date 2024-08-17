class_name CharacterReflection extends Sprite2D

var bottom_world_raycast: RayCast2D

@onready var original_sprite: Sprite2D = get_node("../Sprite2D")

func _init() -> void:
	z_index = -3
	modulate.a = 0.4

func _ready() -> void:
	#var duplicate_parent: Node2D = get_parent().duplicate(8)
	#duplicate_parent.set_script(null)
	#_analize_children(duplicate_parent)
	#add_child(duplicate_parent)

	# FIXME: due to a godot bug (https://github.com/godotengine/godot/issues/66842), the shader parameters are not exported, so I have to set them manually by code
	var shader_material: ShaderMaterial = material
	shader_material.set_shader_parameter("speed", 0.15)
	shader_material.set_shader_parameter("frequency_y", 5)
	shader_material.set_shader_parameter("frequency_x", 10)
	shader_material.set_shader_parameter("amplitude_y", 0.3)
	shader_material.set_shader_parameter("amplitude_x", 0.8)

	texture = original_sprite.texture
	hframes = original_sprite.hframes
	vframes = original_sprite.vframes
	original_sprite.texture_changed.connect(func() -> void:
		texture=original_sprite.texture
	)

	scale.y = -1

	bottom_world_raycast = RayCast2D.new()
	bottom_world_raycast.target_position = Vector2.DOWN * 12
	get_parent().call_deferred("add_child", bottom_world_raycast)

func _process(_delta: float) -> void:
	frame = original_sprite.frame
	flip_h = original_sprite.flip_h
	rotation = original_sprite.rotation
	position.y = original_sprite.position.y * - 1

	if bottom_world_raycast.is_colliding() and visible:
		hide()
	elif not bottom_world_raycast.is_colliding() and not visible:
		show()

#func _analize_children(node: Node) -> void:
	#for child: Node in node.get_children():
		#if not child is Node2D or child is CollisionShape2D or child is CollisionPolygon2D:
			#child.free()
			#continue
#
		#child.set_script(null)
		#_analize_children(child)
