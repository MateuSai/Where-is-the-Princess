@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/boss_druid/druid_scepter.png")
class_name Scepter extends RangedWeapon

@onready var pivot: Node2D = $Pivot

func _ready() -> void:
	super()

func move(mouse_direction: Vector2) -> void:
	super(mouse_direction)

	if mouse_direction.x >= 0:
		#pivot_2.scale.x = 1
		pivot.scale.y = 1
		#pivot_2.rotation = 0
	else:
		#pivot_2.scale.x = -1
		pivot.scale.y = -1
		#pivot_2.rotation = PI/2

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_weapon_ability") and has_active_ability() and not is_busy() and can_active_ability():
		_charge()
	elif event.is_action_released("ui_weapon_ability") and has_active_ability() and can_active_ability():
		#var complete_current_animation: PackedStringArray = animation_player.current_animation.split("/")
		#var current_animation: String = complete_current_animation[complete_current_animation.size() - 1]
		if animation_player.is_playing() and get_current_animation().begins_with("charge") and weapon_sprite.material.get("shader_parameter/active"):
			_active_ability()
		#elif weapon_sprite.frame > 0:
			#_bow_attack(1.0)
		else:
			animation_player.play("RESET")
	elif event.is_action_pressed("ui_attack") and not is_busy():
		_attack()
