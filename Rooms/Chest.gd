@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/chest_closed_anim_f0.png")
class_name Chest extends StaticBody2D

const FRAMES: Array[Array] = [
	[
		[ preload ("res://Art/common_chest_closed.png"), preload ("res://Art/common_chest_opened.png")],
		[ preload ("res://Art/rare_chest_closed.png"), preload ("res://Art/rare_chest_opened.png")]
	],
	[
		[ preload ("res://Art/gear_chest_closed.png"), preload ("res://Art/gear_chest_opened.png")],
		[ preload ("res://Art/gear_chest_closed.png"), preload ("res://Art/gear_chest_opened.png")],
	]
]

const CURSED_CHEST_FRAMES: Array[Texture2D] = [
	preload ("res://Art/cursed_chest_closed.png"),
	preload ("res://Art/cursed_chest_opened.png")
]

enum Type {
	ITEM,
	GEAR,
}
enum GearType {
	WEAPON,
	ARMOR,
}

@export var item_path: String = ""
@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
@export var type: Type = -1
var gear_type: GearType

@onready var room: DungeonRoom = get_parent()
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var interact_area: InteractArea = get_node("InteractArea")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	(get_tree().current_scene as Game).player_added.connect(func() -> void:
		var cursed: bool = false

		var item_quality: Item.Quality
		if item_path.is_empty():
			type = Type.values()[randi() % Type.values().size()] if type == - 1 else type
			item_quality = Item.Quality.CHINGON if randf_range(0, 100) < clamp(1, 90, 14 + SavedData.run_stats.luck * 2) else Item.Quality.COMMON
	#		var permanent_item_paths: PackedStringArray = SavedData.get_available_permanent_item_paths()
			match type:
				Type.ITEM:
					if randi() % 100 < 8:
						# TODO Pass quality
						cursed = true
						item_path = SavedData.get_random_available_cursed_item_path()
					else:
						item_path = SavedData.get_random_available_item_path(item_quality)
				Type.GEAR:
					gear_type = GearType.values()[randi() % GearType.values().size()]
					if gear_type == GearType.WEAPON: # Weapon
						item_quality = Item.Quality.COMMON
						item_path = SavedData.get_random_available_weapon_path()
					else: # Armor
						item_path = SavedData.get_random_available_armor_path(item_quality)
				_:
					push_error("Invalid chest type")
		else:
			gear_type = GearType.ARMOR if item_path.ends_with(".gd") else GearType.WEAPON

		animated_sprite.sprite_frames.clear_all()
		if cursed:
			animated_sprite.sprite_frames.add_frame("default", CURSED_CHEST_FRAMES[0])
			animated_sprite.sprite_frames.add_frame("default", CURSED_CHEST_FRAMES[1])
		else:
			animated_sprite.sprite_frames.add_frame("default", FRAMES[type][item_quality][0])
			animated_sprite.sprite_frames.add_frame("default", FRAMES[type][item_quality][1])

		interact_area.player_interacted.connect(_on_opened)
	)

func _on_opened() -> void:
	interact_area.queue_free()
	animation_player.play("open")

	match type:
		Type.ITEM:
			var item_on_floor: ItemOnFloor = load("res://items/item_on_floor.tscn").instantiate()
			item_on_floor.initialize(load(item_path).new())
			room.add_item_on_floor(item_on_floor, position)
			await create_tween().tween_property(item_on_floor, "position:y", position.y + 16, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).finished
			item_on_floor.enable_pick_up()
		Type.GEAR:
			match gear_type:
				GearType.WEAPON:
		#			var shfbsdkf = load(item_path)
					var weapon: Weapon = load(item_path).instantiate()
					get_tree().current_scene.add_child(weapon)
					weapon.interpolate_pos(global_position, global_position + Vector2.DOWN * 16, false)
				GearType.ARMOR:
					var item_on_floor: ItemOnFloor = load("res://items/item_on_floor.tscn").instantiate()
					var armor_item: ArmorItem = ArmorItem.new()
					armor_item.initialize(load(item_path).new())
					item_on_floor.initialize(armor_item)
					room.add_item_on_floor(item_on_floor, position)
					await create_tween().tween_property(item_on_floor, "position:y", position.y + 16, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).finished
					item_on_floor.enable_pick_up()
				_:
					push_error("Invalid gear type")
		_:
			push_error("Invalid chest type")
