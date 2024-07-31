class_name ItemOnFloor extends Sprite2D

const SHINE_TEX: Texture = preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/item_shine_anim_5x5.png")
const CURSED_PARTICLES_SCENE: PackedScene = preload ("res://effects/cursed_particles.tscn")

var item: Item
#var can_pick_up: bool = false

@onready var interact_area: InteractArea = get_node("InteractArea")
@onready var spawn_shine_effect_timer: Timer = $SpawnShineEffectTimer
@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	interact_area.body_entered.connect(func(player: Player) -> void:
		if can_pick_up_item(player):
			interact_area.sprite_material.set("shader_parameter/color", Color.WHITE)
			# interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
		else:
			interact_area.sprite_material.set("shader_parameter/color", Color.RED)
			interact_area.sprite_material.set("shader_parameter/interior_color", Color("#8f20178d"))
	)
	interact_area.body_exited.connect(func(player: Player) -> void:
		if not can_pick_up_item(player):
			interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
	)

func enable_pick_up() -> void:
	if is_queued_for_deletion():
		return

	interact_area.player_interacted.connect(func() -> void:
		if not can_pick_up_item(Globals.player):
			interact_area.sprite_material.set("shader_parameter/color", Color.RED)
			interact_area.sprite_material.set("shader_parameter/interior_color", Color("#8f20178d"))
			return

		_pick_item_and_free()
	)

	if item is CursedPermanentArtifact:
		add_child(CURSED_PARTICLES_SCENE.instantiate())
	else:
		spawn_shine_effect_timer.timeout.connect(_spawn_shine_effect)
		visible_on_screen_notifier.screen_entered.connect(spawn_shine_effect_timer.start)
		visible_on_screen_notifier.screen_exited.connect(spawn_shine_effect_timer.stop)

## Call after _ready
@warning_ignore("shadowed_variable")
func initialize(item: Item) -> void:
	self.item = item
	if item is Rune:
		texture = item.get_icon()
		var sprite: Sprite2D = Sprite2D.new()
		sprite.material = load("res://unshaded.tres")
		sprite.texture = (item as Rune).get_symbol()
		add_child(sprite)
	else:
		texture = item.get_icon()

func can_pick_up_item(player: Player) -> bool:
	return item.can_pick_up(player)

func _pick_item_and_free() -> void:
	if item is ArrowModifier:
		#print("hahaha")
		assert(Globals.player.weapons.current_weapon is BowOrCrossbowWeapon)

		# Create a new item on floor wwith the current arrow type
		var current_arrow_type_item_on_floor: ItemOnFloor = preload ("res://items/item_on_floor.tscn").instantiate()
		current_arrow_type_item_on_floor.position = position
		get_tree().current_scene.add_child(current_arrow_type_item_on_floor)
		current_arrow_type_item_on_floor.initialize([load("res://items/Passive/WeaponModifiers/arrows/normal_arrow_modifier.gd"), load("res://items/Passive/WeaponModifiers/arrows/homing_arrow_modifier.gd"), load("res://items/Passive/WeaponModifiers/arrows/piercing_arrow_modifier.gd"), load("res://items/Passive/WeaponModifiers/arrows/bouncing_arrow_modifier.gd"), load("res://items/Passive/WeaponModifiers/arrows/explosive_arrow_modifier.gd")][Globals.player.weapons.current_weapon.arrow_type].new())
		current_arrow_type_item_on_floor.enable_pick_up()
	elif item is ArmorItem:
		# TODO make NoArmor item icon
		if not Globals.player.armor is Underpants:
			var item_on_floor: ItemOnFloor = load("res://items/item_on_floor.tscn").instantiate()
			item_on_floor.position = position
			var armor_item: ArmorItem = ArmorItem.new()
			armor_item.initialize(Globals.player.armor)
			item_on_floor.initialize(armor_item)
			get_parent().add_child(item_on_floor)
			item_on_floor.enable_pick_up()

	if item is ArmorShard or DoubleArmorShard:
		if randf_range(0, 100) < Globals.player.armor_shard_break_probability:
			var destroy_effect: Node2D
			if item is ArmorShard:
				destroy_effect = load("res://effects/armor_shard_destroy_effect.tscn").instantiate()
			else:
				destroy_effect = load("res://effects/double_armor_shard_destroy_effect.tscn").instantiate()
			destroy_effect.position = position
			get_parent().add_child(destroy_effect)

			queue_free()
			return

	item.pick_up(interact_area.player)
	queue_free()

func _spawn_shine_effect() -> void:
	var animated_sprite: AnimatedSprite2D = AnimatedSprite2D.new()
	animated_sprite.z_index = 1
	animated_sprite.position.x = randf_range( - 2.5, 2.5)
	animated_sprite.position.y = randf_range( - 2.5, 2.5)
	animated_sprite.material = load("res://unshaded.tres")
	animated_sprite.sprite_frames = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/item_shine_spriteframes.tres")
	animated_sprite.animation_finished.connect(animated_sprite.queue_free)
	add_child(animated_sprite)

	var time: float = (1 / 10.0) * animated_sprite.sprite_frames.get_frame_count("default")
	animated_sprite.play("default")
	var t: Tween = create_tween()
	t.set_parallel()
	t.tween_property(animated_sprite, "rotation", [1, -1][randi() % 2] * 1.5, time)
