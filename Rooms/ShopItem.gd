class_name ShopItem extends ItemOnFloor

var price: int = 10


@warning_ignore("shadowed_variable")
func initialize(item: Item) -> void:
	super(item)


func _ready() -> void:
	super()

	enable_pick_up()


func can_pick_up_item(player: Player) -> bool:
	if SavedData.run_stats.coins < price:
		return false
	return item.can_pick_up(Globals.player)


func _pick_item_and_free() -> void:
	var sound: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sound.stream = load("res://Audio/Sounds/Change-www.fesliyanstudios.com.mp3")
	sound.position = global_position
	sound.bus = "Sounds"
	sound.finished.connect(func():
		sound.queue_free()
	)
	get_tree().current_scene.add_child(sound)
	sound.play()

	super()
