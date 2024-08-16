class_name Armor extends Resource

const ARMOR_FOLDER_PATH: String = "res://Armors/"

var name: String: get = get_armor_name # # Name of the armor
var description: String: get = get_description # # Armor's description
var sprite_sheet: Texture2D: get = get_sprite_sheet # # Armor's spritesheet
var icon: Texture2D: get = get_icon # # Icon of the armor

signal condition_changed(new_condition: int)
## The armor will also receive the damage taken by the player. When the condition reaches 0, the armor will be destroyed and you be in your underpants
@export var condition: int:
	set(new_condition):
		condition = clamp(new_condition, 0, max_condition)
		condition_changed.emit(condition)
var max_condition: int

var ability_icon: Texture2D = null
## Internal variable used to know if we can use the ability (when the cooldown time ends)
var is_able_to_use_ability: bool = true:
	set(new_value):
		if new_value != is_able_to_use_ability:
			is_able_to_use_ability = new_value
			if not is_able_to_use_ability:
				ability_used.emit()
signal ability_used()
var recharge_time: float = 2 ## # Time the ability needs to recharge
var effect_duration: float = -1 # ## Time the ability is active. For example, if the armor grants immortality, the time the player will be immortal.
signal ability_effect_ended()

var effects: Array[ItemEffect] = []

@warning_ignore("shadowed_variable")
func initialize(condition: int) -> void:
	self.max_condition = condition
	self.condition = condition

func equip(player: Player) -> void:
	for effect: ItemEffect in effects:
		effect.enable(player)

func unequip(player: Player) -> void:
	for effect: ItemEffect in effects:
		effect.disable(player)

func _setup_ability(ability_icon: Texture2D, recharge_time: float=2, effect_duration: float=- 1) -> void:
	self.ability_icon = ability_icon
	self.recharge_time = recharge_time
	self.effect_duration = effect_duration

func has_ability() -> bool:
	return ability_icon != null

func enable_ability_effect(_player: Player) -> void:
	pass

func disable_ability_effect(_player: Player) -> void:
	pass

## By default will use the name of the script in this format FILE_NAME. Overwrite this function if you want a different name than the script name or you don't want to add translations
func get_armor_name() -> String:
	return (get_script() as Script).get_path().get_basename().get_file().to_snake_case().to_upper()

## By default will use the name of the script in this format FILE_NAME_DESCRIPTION. Overwrite this function if you don't want to add translations
func get_description() -> String:
	return (get_script() as Script).get_path().get_basename().get_file().to_snake_case().to_upper() + "_DESCRIPTION"

func get_sprite_sheet() -> Texture2D:
	return null

func get_icon() -> Texture2D:
	return null

func get_quality() -> Item.Quality:
	return Item.Quality.COMMON if ability_icon == null else Item.Quality.CHINGON

static func id_to_path(id: String) -> String:
	id = id.to_lower()
	var path: String = ""

	var dir: DirAccess = DirAccess.open(ARMOR_FOLDER_PATH)
	for dir_name: String in dir.get_directories():
		if dir_name == id:
			path = ARMOR_FOLDER_PATH.path_join(dir_name).path_join(dir_name + ".gd")
			break

	return path

static func get_id_from_path(path: String) -> String:
	return path.get_file().trim_suffix(".gd").to_snake_case()

static func get_fragments_by_path(path: String) -> Array[Texture2D]:
	var fragment_textures: Array[Texture2D] = []

	var fragments_folder: DirAccess = DirAccess.open(path.get_base_dir().path_join("fragments"))
	if fragments_folder:
		for file: String in fragments_folder.get_files():
			if not file.trim_suffix(".import").get_extension() == "png":
				continue

			var fragment_texture: Texture2D = load(fragments_folder.get_current_dir().path_join(file).trim_suffix(".import"))
			fragment_textures.push_back(fragment_texture)
	else:
		Log.warn("Armor " + path + " does not have fragments. Create a folder called fragments in the same directory as the armor script and add the fragments on that folder")

	return fragment_textures
