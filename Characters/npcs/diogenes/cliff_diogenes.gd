extends Node2D

@onready var diogenes: NPC = $Diogenes
@onready var animation_player: AnimationPlayer = $DiogenesAnimationPlayer

func _ready() -> void:
	(diogenes.get_node("LifeComponent") as LifeComponent).died.connect(func() -> void:
		animation_player.play("throw")
		SavedData.data.kill_npc(diogenes.id)
	, CONNECT_ONE_SHOT)
