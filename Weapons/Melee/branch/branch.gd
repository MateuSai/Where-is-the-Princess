class_name Branch extends MeleeWeapon


const NO_LEAFS_TEXTURE: Texture2D = preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/branch_without_leaves.png")


func _ready() -> void:
	super()

	hitbox.collided_with_something.connect(_on_first_collide)


func _on_first_collide(body: Node2D) -> void:
	weapon_sprite.texture = NO_LEAFS_TEXTURE
	hitbox.collided_with_something.disconnect(_on_first_collide)
