class_name Skull extends Fragment

@onready var hurtbox_col: CollisionShape2D = $HurtBox/CollisionShape2D

func _ready() -> void:
	super()

	await get_tree().create_timer(0.3, false).timeout
	hurtbox_col.set_deferred("disabled", false)
