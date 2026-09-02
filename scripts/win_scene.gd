extends Node2D

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var victory_image: TextureRect = $VictoryImage
@onready var continue_button: Button = $ContinueButton

const FADE_TIME: float = 0.6

func _ready() -> void:
	audio.play()
	continue_button.pressed.connect(_on_continue_pressed)

	victory_image.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(victory_image, "modulate:a", 1.0, FADE_TIME)

func _on_continue_pressed() -> void:
	Transition.fade_to_scene("res://scenes/menu.tscn")
