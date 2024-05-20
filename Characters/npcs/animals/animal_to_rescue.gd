@tool
class_name AnimalToRescue extends Marker2D

@export var animal: Data.AnimalsToRescue = Data.AnimalsToRescue.CAT_1:
    set(new_animal):
        animal = new_animal
        _spawn_animal()

var animal_instance: NPC

func _ready() -> void:
    if not Engine.is_editor_hint():
        if SavedData.data.is_animal_rescued(animal):
            queue_free()

    _spawn_animal()

func _spawn_animal() -> void:
    if get_child_count() > 0:
        get_child(0).free()

    animal_instance = Data.get_animal_scene(animal).instantiate()
    add_child(animal_instance)
    animal_instance.interact_area.player_interacted.connect(_on_animal_to_rescue_interacted)

func _on_animal_to_rescue_interacted() -> void:
    animal_instance.interact_area.player_interacted.disconnect(_on_animal_to_rescue_interacted)

    SavedData.data.rescue_animal(animal)