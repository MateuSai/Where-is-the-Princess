class_name ShopItem extends ItemOnFloor

const HOLOGRAM_SHADER: Shader = preload("res://shaders_and_particles/hologram.gdshader")
const HOLOGRAM_TEXTURE: Texture = preload("res://Art/hologram_lines-b1399a8d.png")

const SPEND_SOULS_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Squishy/Squishy1.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Squishy/Squishy2.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Squishy/Squishy4.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Squishy/Squishy5.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Squishy/Squishy6.wav")]

var price: int = 10
var price_always_visible: bool

@onready var price_container: HBoxContainer = $HBoxContainer
@onready var price_label: Label = %PriceLabel
@onready var currency_icon: TextureRect = $HBoxContainer/TextureRect


@warning_ignore("shadowed_variable")
func initialize(item: Item) -> void:
	super(item)

	price_always_visible = Settings.shop_prices_always_visible
	if not price_always_visible:
		price_container.hide()
	Settings.shop_prices_always_visible_changed.connect(func(new_value: bool) -> void:
		price_always_visible = new_value
		if price_always_visible:
			price_container.show()
		elif not is_processing_unhandled_input():
			price_container.hide()
	)

	if SavedData.get_biome_conf().name != "BASE_CAMP":
		await (get_tree().current_scene as Game).player_added
		_update_coin_price(Globals.player.shop_discount)
		Globals.player.shop_discount_changed.connect(func(new_value: float) -> void:
			_update_coin_price(new_value)
		)
#		price = round(item.get_coin_cost() * (1 - Globals.player.shop_discount))
		currency_icon.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/small_coin.tres")
	else: # BaseCamp
		assert(SavedData.get_biome_conf().name == "BASE_CAMP")

		price = item.get_dark_soul_cost()
		currency_icon.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/8x8_boss_soul_animation.tres")
		#currency_icon.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/small_coin.tres")

		#var hologram_sprite: Sprite2D = Sprite2D.new()
		#hologram_sprite.texture = texture
		#hologram_sprite.material = ShaderMaterial.new()
		#(hologram_sprite.material as ShaderMaterial).shader = HOLOGRAM_SHADER
		#(hologram_sprite.material as ShaderMaterial).set_shader_parameter("hologramTexture", HOLOGRAM_TEXTURE)
		#add_child(hologram_sprite)

		price_label.text = str(price)


func _ready() -> void:
	super()

	interact_area.player_entered.connect(func() -> void:
		if not price_always_visible:
			price_container.show()
	)
	interact_area.player_exited.connect(func() -> void:
		if not price_always_visible:
			price_container.hide()
	)

	enable_pick_up()

func _update_coin_price(discount: float) -> void:
	price = round(item.get_coin_cost() * (1 - discount))
	price_label.text = str(price)


func can_pick_up_item(player: Player) -> bool:
	if (SavedData.run_stats.coins < price and SavedData.get_biome_conf().name != "BASE_CAMP") or (SavedData.data.dark_souls < price and SavedData.get_biome_conf().name == "BASE_CAMP"):
		return false
	return item.can_pick_up(Globals.player)


func _pick_item_and_free() -> void:
	var sound_stream: AudioStream
	var sound_vol: float = 0.0

	if SavedData.get_biome_conf().name == "BASE_CAMP":
		SavedData.set_dark_souls(SavedData.data.dark_souls - price)
		sound_stream = SPEND_SOULS_SOUNDS.pick_random()
		sound_vol = 3
	else:
		SavedData.run_stats.coins -= price
		sound_stream = load("res://Audio/Sounds/Change-www.fesliyanstudios.com.mp3")
		sound_vol = 16

	var sound: AutoFreeSound = AutoFreeSound.new()
	#sound.stream = load("res://Audio/Sounds/Change-www.fesliyanstudios.com.mp3")
	#sound.position = global_position
	#sound.bus = "Sounds"
	#sound.finished.connect(func() -> void:
		#sound.queue_free()
	#)
	get_tree().current_scene.add_child(sound)
	sound.start(sound_stream, global_position, sound_vol)

	#if get_tree().current_scene.name == "Game":
	super()
	#else: # BaseCamp
		#if item is WeaponItem:
			#var weapon_item: WeaponItem = item
			#SavedData.add_extra_available_weapon(weapon_item.scene_file_path)
		#elif item is TemporalArtifact:
			#SavedData.add_extra_available_temporal_artifact((item.get_script() as Script).get_path())
		#queue_free()
