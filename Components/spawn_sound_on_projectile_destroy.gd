class_name SpawnSoundOnProjectileDestroy extends Node

@export var sounds: Array[AudioStream] = []

@onready var projectile: Projectile = get_parent()

func _ready() -> void:
    projectile.destroyed.connect(func() -> void:
        var auto_free_sound: AutoFreeSound=AutoFreeSound.new()
        get_tree().current_scene.add_child(auto_free_sound)
        auto_free_sound.start(sounds[randi() % sounds.size()], projectile.global_position)
    )
