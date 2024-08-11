class_name ReptilianSpear extends MeleeWeapon

var spear_and_rope: WeaponWithRope

@onready var pick_up_spear_area: Area2D = $PickUpSpearArea
@onready var pick_up_spear_area_col: CollisionShape2D = $PickUpSpearArea/CollisionShape2D
@onready var pull_back_timer: Timer = $PullBackTimer

func _ready() -> void:
	super()

	pick_up_spear_area_col.disabled = true
	pick_up_spear_area.body_entered.connect(_on_pick_up_spear_area_body_entered)

	pull_back_timer.timeout.connect(_pull_back_weapon)

func is_busy() -> bool:
	return super() or not weapon_sprite.visible

func throw() -> void:
	pick_up_spear_area_col.disabled = true
	weapon_sprite.hide()

	spear_and_rope = load("res://Characters/Enemies/toasted_mark/SpearAndRope.tscn").instantiate()
	get_tree().current_scene.add_child(spear_and_rope)
	spear_and_rope.position = global_position
	var dir: Vector2 = Vector2.RIGHT.rotated(rotation)
	if dir.x < 0:
		spear_and_rope.scale.y = -1
	spear_and_rope.attach(get_parent().get_parent().get_path(), dir)
	spear_and_rope.hitbox.weapon = self
	spear_and_rope.hitbox.damage_dealer = get_parent().get_parent()
	spear_and_rope.hitbox.damage_dealer_id = (get_parent().get_parent() as Character).id

	pull_back_timer.start(randf_range(0.8, 1.4))

func _pull_back_weapon() -> void:
	Log.debug("Pulling back spear...")
	pick_up_spear_area_col.set_deferred("disabled", false)
	spear_and_rope.start_pulling()

func _on_pick_up_spear_area_body_entered(body: Node2D) -> void:
	Log.debug("body entered pickup spear area")
	if is_instance_valid(spear_and_rope) and body == spear_and_rope.weapon_body:
		Log.debug("Picking up spear")
		animation_player.play("RESET")
		pick_up_spear_area_col.set_deferred("disabled", true)
		spear_and_rope.queue_free()
		weapon_sprite.show()
