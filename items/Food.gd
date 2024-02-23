class_name Food extends Item

static var extra_hp: int = 0

const POSSIBLE_ICONS: Array[Texture] = [preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/food_apple.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/food_banana.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/food_chicken.png"), preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/food_ham.png")]

var icon: Texture


func _init() -> void:
	icon = POSSIBLE_ICONS[randi() % POSSIBLE_ICONS.size()]


func get_icon() -> Texture2D:
	return icon


func can_pick_up(player: Player) -> bool:
	return player.life_component.max_hp > player.life_component.hp


func pick_up(player: Player) -> void:
	player.life_component.hp += 1 + extra_hp
	player.eat_sound.play()
