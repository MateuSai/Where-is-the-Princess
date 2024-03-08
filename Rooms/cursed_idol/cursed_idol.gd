class_name CursedIdol extends StaticBody2D

var coin_price: int = 10

var permanent_passive_item: PermanentPassiveItem
var item_in_the_process_of_cursing: PermanentPassiveItem
var tween: Tween = null

@onready var room: DungeonRoom = owner

@onready var interact_area: InteractArea = get_node("InteractArea")
@onready var cost_hbox: HBoxContainer = $CostHBox


func _ready() -> void:
	cost_hbox.hide()

	interact_area.body_entered.connect(func(_player: Player) -> void:
		cost_hbox.show()
		if _can_interact():
			interact_area.sprite_material.set("shader_parameter/color", Color.WHITE)
			# interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
		else:
			interact_area.sprite_material.set("shader_parameter/color", Color.RED)
			interact_area.sprite_material.set("shader_parameter/interior_color", Color("#8f20178d"))
	)
	interact_area.body_exited.connect(func(_player: Player) -> void:
		cost_hbox.hide()
		if not _can_interact():
			interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
	)

	interact_area.player_interacted.connect(_on_player_interacted)


func _on_player_interacted() -> void:
	if not _can_interact():
		return

	item_in_the_process_of_cursing = permanent_passive_item

	Globals.player.unequip_passive_item(item_in_the_process_of_cursing)
	SavedData.run_stats.coins -= coin_price

	var item_icon: Sprite2D = Sprite2D.new()
	item_icon.texture = item_in_the_process_of_cursing.get_icon()
	add_child(item_icon)
	item_icon.global_position = Globals.player.global_position

	tween = create_tween()
	tween.tween_property(item_icon, "global_position", global_position, 2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(item_icon.queue_free)
	tween.finished.connect(_spawn_cursed_item)


func _spawn_cursed_item() -> void:
	var item_on_floor: ItemOnFloor = (load("res://items/item_on_floor.tscn") as PackedScene).instantiate()
	room.add_item_on_floor(item_on_floor, position)
	item_on_floor.initialize((load(item_in_the_process_of_cursing.get_cursed_version_path()) as GDScript).new())

	tween = create_tween()
	tween.tween_property(item_on_floor, "position:y", position.y + 16, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(item_on_floor.enable_pick_up)
	tween.finished.connect(func() -> void:
		tween = null
	)


func _can_interact() -> bool:
	permanent_passive_item = _get_random_permanent_passive_item_that_has_cursed_version()
	return tween == null and SavedData.run_stats.coins >= coin_price and permanent_passive_item


func _get_random_permanent_passive_item_that_has_cursed_version() -> PermanentPassiveItem:
	var player_permanent_passive_items: Array[PermanentPassiveItem] = SavedData.run_stats.get_permanent_passive_items().duplicate(false)
	player_permanent_passive_items.shuffle()

	for item: PermanentPassiveItem in player_permanent_passive_items:
		if not item.get_cursed_version_path().is_empty():
			return item

	return null
