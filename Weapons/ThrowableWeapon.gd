@icon("res://Art/weapons/spear.png")
class_name ThrowableWeapon extends Weapon

var throw_dir: Vector2

@onready var weapon_sprite: Sprite2D = get_node("Node2D/Sprite2D")


func _ready() -> void:
	super()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	position += throw_dir * 50 * delta


func throw() -> void:
	throw_dir = Vector2.RIGHT.rotated(weapon_sprite.global_rotation - PI/4)
	get_parent().throw_weapon()
	set_physics_process(true)
