class_name TribalMask extends Sprite2D

enum Type { BLOWPIPE, SPEAR, BOMB, SHAMAN }

var type: Type

@onready var room: DungeonRoom = get_parent()


func _init() -> void:
	add_to_group("tribal_masks")


@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
func initialize(type: Type, flip_h: bool) -> void:
	self.type = type
	texture = load(["res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/tribals/tribal_01_mask.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/tribals/tribal_02_mask.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/tribals/tribal_03_mask.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/tribals/tribal_04_mask.png"][type])
	self.flip_h = flip_h


func _ready() -> void:
	var initial_y: float = position.y
	position.y -= 4
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.tween_property(self, "position:y", initial_y, 0.25)
	tween.tween_property(self, "position:y", initial_y - 2, 0.25)
	tween.tween_property(self, "position:y", initial_y, 0.25)


func resurrect() -> void:
	var enemy: Enemy = load(["res://Characters/Enemies/BlowpipeTribal/BlowpipeTribal.tscn", "res://Characters/Enemies/SpearTribal/SpearTribal.tscn", "res://Characters/Enemies/BombTribal/BombTribal.tscn", "res://Characters/Enemies/ShamanTribal/ShamanTribal.tscn"][type]).instantiate()
	enemy.position = position
	room.add_enemy(enemy)

	queue_free()
