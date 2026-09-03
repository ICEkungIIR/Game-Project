# scripts/managers/music_manager.gd
extends Node

## Autoload singleton: MusicManager
## Add as Autoload named "Music" in Project Settings.

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

@export var farm_track: AudioStream
@export var tavern_track: AudioStream


func _ready() -> void:
	player.finished.connect(_on_finished)  # loop manually if stream isn't set to loop


func play_track(track: AudioStream, fade_in: bool = true) -> void:
	if player.stream == track and player.playing:
		return
	player.stream = track
	player.volume_db = -40.0 if fade_in else 0.0
	player.play()
	if fade_in:
		var tween := create_tween()
		tween.tween_property(player, "volume_db", -15.0, 1.5)


func stop() -> void:
	player.stop()


func _on_finished() -> void:
	player.play()  # simple loop fallback
