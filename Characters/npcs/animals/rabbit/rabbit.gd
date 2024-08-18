class_name Rabbit extends Animal

var mov_direction: Vector2 = Vector2.ZERO

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var pathfinding_component: PathfindingComponent = $PathfindingComponent

func _ready() -> void:
	super()

	if room is BaseCamp:
		($NavigationAgent2D as NavigationAgent2D).set_navigation_map(room.get_navigation_map())
		pathfinding_component.mode = pathfinding_component.Wander.new()
		set_physics_process(true)
		animated_sprite.play("move")
	else:
		set_physics_process(false)

func _physics_process(_delta: float) -> void:
	mov_direction = (($NavigationAgent2D as NavigationAgent2D).get_next_path_position() - global_position).normalized()
	move_and_collide(mov_direction * 0.3)

	if mov_direction.x > 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	elif mov_direction.x < 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
