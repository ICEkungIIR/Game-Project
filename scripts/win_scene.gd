extends Node2D

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var continue_button: Button = $ContinueButton

func _ready() -> void:
	audio.play()
	anim.play("win_intro")
	continue_button.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	Transition.fade_to_scene("res://scenes/menu.tscn")
