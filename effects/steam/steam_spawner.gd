class_name SteamSpawner extends Marker2D

const STEAM_CLOUD_SCENE: PackedScene = preload("res://effects/steam/steam_cloud.tscn")

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.timeout.connect(func() -> void:
		var steam_cloud: SteamCloud = STEAM_CLOUD_SCENE.instantiate()
		steam_cloud.position.y -= steam_cloud.offset.y
		add_child(steam_cloud)
	)
