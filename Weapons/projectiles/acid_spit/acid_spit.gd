class_name AcidSpit extends Projectile


const SPIT_SPLASH_SCENE: PackedScene = preload("res://Weapons/projectiles/acid_spit/spit_splash.tscn")


func _ready() -> void:
	super()

	$Sprite2D.frame = randi() % 4


func destroy() -> void:
	var splash: SpitSplash = SPIT_SPLASH_SCENE.instantiate()
	splash.global_position = global_position
	get_tree().current_scene.add_child(splash)

	super()
