class_name LightningAreaAttack extends Hitbox


func _ready() -> void:
	super()

	var textures: Array[Texture] = [load("res://Art/effects/big_ray_01_64x64.png"), load("res://Art/effects/big_ray_02_64x64.png"), load("res://Art/effects/big_ray_03_64x64.png")]
	$Sprite2D.texture = textures[randi() % textures.size()]


func attack(dir: Vector2) -> void:
	global_rotation = dir.angle() - PI/2
	knockback_direction = dir
