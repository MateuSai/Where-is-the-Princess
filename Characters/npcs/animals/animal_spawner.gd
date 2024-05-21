@tool
class_name AnimalSpawner extends Marker2D

@export var animal: Data.AnimalsToRescue = Data.AnimalsToRescue.BLACK_CAT:
    set(new_animal):
        animal = new_animal
        _spawn_animal()

func _ready() -> void:
    if not Engine.is_editor_hint():
        if not SavedData.data.is_animal_rescued(animal):
            queue_free()

    _spawn_animal()

func _spawn_animal() -> void:
    if get_child_count() > 0:
        get_child(0).free()

    var animal_instance: NPC = Data.get_animal_scene(animal).instantiate()
    add_child(animal_instance)