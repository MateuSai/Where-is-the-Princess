@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/arrow.png")
class_name Arrow extends Projectile

const WORLD_IMPACT_SOUNDS: Array[AudioStreamWAV] = [preload("res://Audio/Sounds/impact/521242__cyoung510__arrow_hits_target_1.wav"), preload("res://Audio/Sounds/impact/521242__cyoung510__arrow_hits_target_2.wav"), preload("res://Audio/Sounds/impact/521242__cyoung510__arrow_hits_target_3.wav")]
const TEXTURES: Array[Texture] = [preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/arrow.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/homing_arrow.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/piercing_arrow.png")]
const MODIFIER_TEXTURES: Array[Texture] = [preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/default_arrow_icon.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/homing_arrow_icon.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/piercing_arrow_icon.png")]

enum Type {
	NORMAL,
	HOMING,
	PIERCING,
}
var type: Type = Type.NORMAL: set = _set_type

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	super()

	flesh_sounds = MeleeWeapon.IMPACT_FLESH_SOUNDS


func _collide(node: Node2D, _dam: int = damage) -> void:
	collided_with_something.emit(node)

	if node.get("life_component") != null:
		node.life_component.take_damage(damage, knockback_direction, knockback_force)
		if bodies_pierced >= piercing:
			_attach_projectile(node)
		else:
			bodies_pierced += 1
	else:
		if bounces_remaining > 0:
			bounces_remaining -= 1
			_bounce()
		else:
			_attach_projectile(node)


func _attach_projectile(body: Node2D) -> void:
	var sprite_clone: Sprite2D = $Sprite2D.duplicate()

	if body is CharacterBody2D:
		body.add_child(sprite_clone)
	else:
		var sound: AutoFreeSound = AutoFreeSound.new()
		get_tree().current_scene.add_child(sound)
		sound.start(WORLD_IMPACT_SOUNDS[randi() % WORLD_IMPACT_SOUNDS.size()], position, -5)
		get_tree().current_scene.add_child(sprite_clone)

	sprite_clone.rotation += rotation
	sprite_clone.global_position = position

	destroy()


func destroy() -> void:
	super()


func _set_type(new_type: Type) -> void:
	type = new_type
	sprite.texture = TEXTURES[type]
	match type:
		Type.NORMAL:
			pass
		Type.HOMING:
			var homing_component: HomingComponent = HOMING_COMPONENT_SCENE.instantiate()
			homing_component.homing_degree = 0.05
			add_child(homing_component)
		Type.PIERCING:
			piercing += 1
