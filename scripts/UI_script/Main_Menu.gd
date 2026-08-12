extends Node2D

@onready var video: VideoStreamPlayer = $Control/VideoStreamPlayer

func _ready() -> void:
    video.play()

    var intro_length: float = 2.2
    await get_tree().create_timer(intro_length).timeout
    _on_intro_finished()

func _process(delta: float) -> void:
    pass

func _on_start_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/saved_world.tscn")

func _on_credits_pressed() -> void:
    print("Credits scene not built yet")

func _on_setting_pressed() -> void:
    print("Setting scene not built yet")

func _on_exit_pressed() -> void:
    get_tree().quit()

func _on_intro_finished() -> void:
    get_tree().change_scene_to_file("res://scenes/menu.tscn")