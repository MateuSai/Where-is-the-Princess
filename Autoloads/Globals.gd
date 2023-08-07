extends Node

var run_seed: int

signal room_closed()
signal room_cleared()

var player: Player = null

const ENEMIES_FOLDER_PATH: String = "res://Characters/Enemies/"
var ENEMIES = {}


func _ready() -> void:
	var enemies_folder: DirAccess = DirAccess.open(ENEMIES_FOLDER_PATH)
	assert(enemies_folder != null)
	for enemy_folder in enemies_folder.get_directories():
		if not enemies_folder.file_exists(enemy_folder + "/" + enemy_folder + ".tscn"):
			push_error(enemy_folder + "/" + enemy_folder + ".tscn" + " not found on " + ENEMIES_FOLDER_PATH)
			continue
		var info: Dictionary = {}
		var info_file: FileAccess = FileAccess.open(ENEMIES_FOLDER_PATH + enemy_folder + "/" + "info.json", FileAccess.READ)
		if info_file != null:
			var json: JSON = JSON.new()
			json.parse(info_file.get_as_text())
			info_file.close()
			info = json.data
		ENEMIES[enemy_folder] = {
			"path": ENEMIES_FOLDER_PATH + enemy_folder + "/" + enemy_folder + ".tscn",
			"info": info,
		}

	#print(ENEMIES)


func get_enemy_paths(biome: String) -> Array[String]:
	var enemy_paths: Array[String] = []

	for enemy in ENEMIES.values():
		if enemy.info.has("biomes"):
			if enemy.info.biomes.has(biome):
				enemy_paths.push_back(enemy.path)

	return enemy_paths
