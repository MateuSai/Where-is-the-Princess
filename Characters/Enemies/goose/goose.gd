class_name Goose extends Enemy

var weapon: Weapon

@onready var weapon_sprite: Sprite2D = $WeaponSprite
@onready var up_wing_pivot: Node2D = $UpWingPivot
@onready var down_wing_pivot: Node2D = $DownWingPivot
#@onready var up_wing: Sprite2D = $UpWing
#@onready var down_wing: Sprite2D = $DownWing
@onready var squawk_sound: AudioStreamPlayer2D = $SquawkSound

func _ready() -> void:
	super()

	life_component.died.connect(func() -> void:
		if weapon:
			room.call_deferred("add_weapon_on_floor", weapon, position)
			weapon.show()
			weapon._on_Tween_tween_completed()
	)

	squawk_sound.finished.connect(func() -> void:
		await get_tree().create_timer(randf_range(0.3, 1.0), false).timeout
		_squawk()
	)

	_squawk()

func _on_change_dir() -> void:
	super()
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

func _squawk() -> void:
	squawk_sound.stream = load("res://Audio/Sounds/goose/474952__sarena6487528__goose-2_%d.wav" % randi_range(1, 7))
	squawk_sound.play()