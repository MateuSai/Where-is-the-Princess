class_name CursedIdol extends NPC

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

var coin_price: int = 10:
	set(new_value):
		coin_price = new_value
		cost_hbox.get_node("Label").text = str(coin_price)
var times_used: int = 0

var permanent_passive_item: PermanentArtifact
var item_in_the_process_of_cursing: PermanentArtifact
var tween: Tween = null

#var canvas_modulate: CanvasModulate

@onready var cost_hbox: HBoxContainer = $CostHBox
@onready var sound: AudioStreamPlayer2D = $Sound


func _ready() -> void:
	super()

	cost_hbox.hide()

	interact_area.body_entered.connect(func(_player: Player) -> void:
		#canvas_modulate = CanvasModulate.new()
		#canvas_modulate.color = Color.BLACK
		#canvas_modulate.light_mask = 2
		#canvas_modulate.z_index = 100
		#get_tree().current_scene.add_child(canvas_modulate)

		#_start_dialogue("Hwy, come over here...")
		cost_hbox.show()
		if _can_interact():
			interact_area.sprite_material.set("shader_parameter/color", Color.WHITE)
			# interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
		else:
			interact_area.sprite_material.set("shader_parameter/color", Color.RED)
			interact_area.sprite_material.set("shader_parameter/interior_color", Color("#8f20178d"))
	)
	interact_area.body_exited.connect(func(_player: Player) -> void:
		#canvas_modulate.queue_free()

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

	times_used += 1
	coin_price += 3 * times_used

	var item_icon: Sprite2D = Sprite2D.new()
	item_icon.texture = item_in_the_process_of_cursing.get_icon()
	add_child(item_icon)
	item_icon.global_position = Globals.player.global_position

	tween = create_tween()
	tween.tween_property(item_icon, "global_position", global_position, 2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(item_icon.queue_free)
	tween.finished.connect(_spawn_cursed_item)


func _spawn_cursed_item() -> void:
	sound.play()
	Globals.start_joy_vibration(0.2, 0.4, 0.2)

	var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
	spawn_explosion.modulate = Color("460e03ba")
	add_child(spawn_explosion)

	var item_on_floor: ItemOnFloor = (load("res://items/item_on_floor.tscn") as PackedScene).instantiate()
	room.add_item_on_floor(item_on_floor, position)
	item_on_floor.initialize((load(item_in_the_process_of_cursing.get_cursed_version_path()) as GDScript).new() as Item)

	tween = create_tween()
	tween.tween_property(item_on_floor, "position:y", position.y + 16, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(item_on_floor.enable_pick_up)
	tween.finished.connect(func() -> void:
		tween = null
	)


func _can_interact() -> bool:
	permanent_passive_item = _get_random_permanent_passive_item_that_has_cursed_version()
	return tween == null and SavedData.run_stats.coins >= coin_price and permanent_passive_item


func _get_random_permanent_passive_item_that_has_cursed_version() -> PermanentArtifact:
	var player_permanent_passive_items: Array[PermanentArtifact] = SavedData.run_stats.get_permanent_passive_items().duplicate(false)
	player_permanent_passive_items.shuffle()

	for item: PermanentArtifact in player_permanent_passive_items:
		if not item.get_cursed_version_path().is_empty():
			return item

	return null


func _start_dialogue(text: String) -> void:
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	dialogue_box.position = Vector2(5, -26)
	add_child(dialogue_box)

	#var available_dialogue_texts: PackedStringArray = dialogue_texts.duplicate()
	#for i: int in range(available_dialogue_texts.size()-1, -1, -1):
		#if used_dialogue_texts.has(available_dialogue_texts[i]):
			#available_dialogue_texts.remove_at(i)
	#if available_dialogue_texts.is_empty():
		#available_dialogue_texts = dialogue_texts.duplicate()
		#used_dialogue_texts = []
	var random_dialogue_text: String = text
	dialogue_box.start_displaying_text(random_dialogue_text)
	#used_dialogue_texts.push_back(random_dialogue_text)

	dialogue_box.finished_displaying_text.connect(func() -> void:
		dialogue_tween = create_tween()
		dialogue_tween.tween_property(dialogue_box, "modulate:a", 0.0, 1).set_delay(3)
		await dialogue_tween.finished
		dialogue_tween = null
		dialogue_box.queue_free()
		dialogue_box = null
		#dialogue_finished.emit()
	)
