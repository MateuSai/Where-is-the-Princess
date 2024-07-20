class_name Archeleton extends Enemy

const NO_HEAD_SPRITESHEET: Texture2D = preload("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Skeleton/skelebro_archer_no_head.png")

var projectile_speed: int = 200

var has_head: bool = true

@onready var bow_container: Node2D = $BowContainer
@onready var bow_sprite: Sprite2D = $BowContainer/Sprite2D
@onready var aim_component: AimComponent = $AimComponent

func _ready() -> void:
	super()

	life_component.damage_taken.connect(func(dam: int, dir: Vector2, force: int) -> void:
		if life_component.hp > 0:
			_remove_head(dam, dir, force)
	, CONNECT_ONE_SHOT)


#func aim_bow() -> void:
	#bow_container.rotation = aim_component.get_dir().dir.angle()


#func _spawn_arrow() -> void:
	#if not is_inside_tree():
		#return
#
	#var arrow: Arrow = load("res://Weapons/projectiles/arrow.tscn").instantiate()
##	arrow.position = bow_sprite.global_position
	#get_tree().current_scene.add_child(arrow)
	#arrow.launch(bow_sprite.global_position, Vector2.RIGHT.rotated(bow_container.rotation), projectile_speed, true)

func _remove_head(dam: int, dir: Vector2, force: int) -> void:
	data.max_speed *= 0.3

	has_head = false
	sprite.texture = NO_HEAD_SPRITESHEET
	aim_component.mode = aim_component.RANDOM_AIM

	var skull: Fragment = load("res://effects/fragments/skull.tscn").instantiate()
	skull.position = position + Vector2.UP * 10
	room.add_child(skull)
	var dis: float = force / 10.0
	skull.throw(self, dir, dis, dis)

	if dam > 4:
		(skull.get_node("LifeComponent") as LifeComponent).take_damage(dam, dir, force, null, null, "")
