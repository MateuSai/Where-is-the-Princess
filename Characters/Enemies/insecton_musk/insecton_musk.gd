class_name InsectonMusk extends Enemy

const BITE_EFFECT_SCENE: PackedScene = preload("res://Characters/Enemies/BiteEffect.tscn")
const ACID_SPIT_SCENE: PackedScene = preload("res://Weapons/projectiles/acid_spit/acid_spit.tscn")

var num_consecutive_spits: int = 0

@onready var wings: Sprite2D = $Wings
@onready var hitbox_col: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var throw_acid_spit_timer: Timer = $ThrowAcidSpitTimer


func _ready() -> void:
	super()

	throw_acid_spit_timer.timeout.connect(spit)


func _on_change_dir() -> void:
	super()

	wings.flip_h = !wings.flip_h


func _spawn_bite_effect() -> void:
	var effect: Sprite2D = BITE_EFFECT_SCENE.instantiate()
	effect.global_position = hitbox_col.global_position
	get_tree().current_scene.add_child(effect)


func spit() -> void:
	num_consecutive_spits += 1

	@warning_ignore("shadowed_variable")
	var spit: AcidSpit = ACID_SPIT_SCENE.instantiate()
	spit.exclude = [self]
	get_tree().current_scene.add_child(spit)
	var throw_pos: Vector2 = global_position + Vector2.UP * 10
	spit.launch(throw_pos, (target.global_position - throw_pos).normalized(), 200)
