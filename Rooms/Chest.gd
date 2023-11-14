@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/chest_closed_anim_f0.png")
class_name Chest extends StaticBody2D

const FRAMES: Array[Array] = [
	[preload("res://Art/common_chest_closed.png"), preload("res://Art/common_chest_opened.png")],
	[preload("res://Art/rare_chest_closed.png"), preload("res://Art/rare_chest_opened.png")]
]

@export var item_path: String = ""

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var interact_area: InteractArea = get_node("InteractArea")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var item_quality: Item.Quality
	if item_path.is_empty():
		item_quality = Item.Quality.CHINGON if randi() % 6 == 0 else Item.Quality.COMMON
#		var permanent_item_paths: PackedStringArray = SavedData.get_discovered_permanent_item_paths()
		item_path = SavedData.get_random_discovered_item_path(item_quality)
	else:
		item_path = load(item_path).new().get_quality()

	animated_sprite.sprite_frames.clear_all()
	animated_sprite.sprite_frames.add_frame("default", FRAMES[item_quality][0])
	animated_sprite.sprite_frames.add_frame("default", FRAMES[item_quality][1])

	interact_area.player_interacted.connect(_on_opened)


func _on_opened() -> void:
	interact_area.queue_free()
	animation_player.play("open")

	var item_on_floor: ItemOnFloor = load("res://items/item_on_floor.tscn").instantiate()
	item_on_floor.position = position
	item_on_floor.initialize(load(item_path).new())
	get_parent().add_child(item_on_floor)
	await create_tween().tween_property(item_on_floor, "position:y", position.y + 16, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).finished
	item_on_floor.enable_pick_up()
