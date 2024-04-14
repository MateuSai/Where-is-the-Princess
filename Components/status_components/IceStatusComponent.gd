class_name IceStatusComponent extends StatusComponent

const ATTACKS_TO_BREAK_ICE: int = 3

var ice_cube: Sprite2D
var shake_component: ShakeComponent
var ice_life_component: LifeComponent
var spawn_fragments_component: SpawnFragmentsOnDied

func _ready() -> void:
	super()

	shake_component = ShakeComponent.new()
	add_child(shake_component)

	ice_cube = Sprite2D.new()
	ice_cube.texture = load("res://Art/16x16 Pixel Art Roguelike (Village) Pack/ice_block.png")
	ice_cube.position.y = -7
	character.add_child(ice_cube)

	ice_life_component = LifeComponent.new()
	ice_life_component.name = "LifeComponent"
	ice_life_component.max_hp = ATTACKS_TO_BREAK_ICE
	ice_life_component.hp = ATTACKS_TO_BREAK_ICE
	add_child(ice_life_component)

	spawn_fragments_component = SpawnFragmentsOnDied.new()
	add_child(spawn_fragments_component)
	spawn_fragments_component.fragment_scene = load("res://effects/fragments/ice_fragment.tscn")
	spawn_fragments_component.min_fragments = 3
	spawn_fragments_component.max_fragments = 4

	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack"):
		ice_life_component.take_damage(1, Vector2.ZERO, 0, null, null, "")
		shake_component.shake(ice_cube)
		if ice_life_component.hp <= 0:
			set_process_unhandled_input(false)
			remove()

func add() -> void:
	#character.modulate = Color.DEEP_SKY_BLUE

	ice_life_component.hp = ATTACKS_TO_BREAK_ICE
	character.can_move = false

	set_process_unhandled_input(true)

	super()

func remove() -> void:
	#character.modulate = Color.WHITE
	ice_cube.queue_free()
	character.can_move = true
	super()
