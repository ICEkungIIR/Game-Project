extends Node2D
@onready var video: VideoStreamPlayer = $Control/VideoStreamPlayer

func _ready() -> void:
	video.play()
	video.finished.connect(_on_video_finished)

func _on_video_finished() -> void:
	Transition.fade_to_scene("res://scenes/world.tscn")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event is InputEventMouseButton:
		if event.pressed:
			_on_video_finished()
