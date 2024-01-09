class_name CrocodileJoe extends Enemy


@onready var hurtbox: HurtBox = $HurtBox
@onready var hitbox: Hitbox = $Hitbox


func _ready() -> void:
	super()

	hitbox.exclude = [self, hurtbox]


func _update_hitbox() -> void:
	hitbox.knockback_direction = (target.global_position - global_position).normalized()
