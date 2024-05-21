class_name Goose extends Enemy

var weapon: Weapon

@onready var weapon_sprite: Sprite2D = $WeaponSprite
@onready var up_wing_pivot: Node2D = $UpWingPivot
@onready var down_wing_pivot: Node2D = $DownWingPivot
#@onready var up_wing: Sprite2D = $UpWing
#@onready var down_wing: Sprite2D = $DownWing

func _ready() -> void:
	super()

	life_component.died.connect(func() -> void:
		if weapon:
			room.call_deferred("add_weapon_on_floor", weapon, position)
			weapon.show()
			weapon._on_Tween_tween_completed()
	)

func _on_change_dir() -> void:
	sprite.flip_h = !sprite.flip_h
	up_wing_pivot.scale.x *= - 1
	down_wing_pivot.scale.x *= - 1
	#up_wing.scale.x *= - 1
	#up_wing.flip_h = !up_wing.flip_h
	#down_wing.scale.x *= - 1
	#down_wing.flip_h = !down_wing.flip_h
	weapon_sprite.scale.x *= - 1
	weapon_sprite.position.x *= - 1

func steal_player_weapon() -> void:
	weapon = Globals.player.weapons.steal_weapon()
	#var weapon_parent: Node = weapon.get_parent()
	#weapon_parent.remove_child(weapon)
	weapon_sprite.texture = weapon.weapon_sprite.texture
	weapon_sprite.frame = weapon.weapon_sprite.frame
	weapon_sprite.offset = weapon.weapon_sprite.offset
	weapon_sprite.hframes = weapon.weapon_sprite.hframes
	weapon_sprite.vframes = weapon.weapon_sprite.vframes