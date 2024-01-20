class_name CharacterReflection extends Sprite2D


@onready var original_sprite: Sprite2D = get_node("../Sprite2D")


func _init() -> void:
	z_index = -3
	modulate.a = 0.4


func _ready() -> void:
	#var duplicate_parent: Node2D = get_parent().duplicate(8)
	#duplicate_parent.set_script(null)
	#_analize_children(duplicate_parent)
	#add_child(duplicate_parent)

	texture = original_sprite.texture
	hframes = original_sprite.hframes
	vframes = original_sprite.vframes
	original_sprite.texture_changed.connect(func() -> void:
		texture = original_sprite.texture
	)

	scale.y = -1


func _process(_delta: float) -> void:
	frame = original_sprite.frame
	flip_h = original_sprite.flip_h
	rotation = original_sprite.rotation
	position.y = original_sprite.position.y * -1


#func _analize_children(node: Node) -> void:
	#for child: Node in node.get_children():
		#if not child is Node2D or child is CollisionShape2D or child is CollisionPolygon2D:
			#child.free()
			#continue
#
		#child.set_script(null)
		#_analize_children(child)
