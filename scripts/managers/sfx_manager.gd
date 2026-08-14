extends Node

## Autoload singleton: SfxManager
## Add as Autoload named "Sfx" in Project Settings.
## Pooled one-shot sound effect player — call Sfx.play(stream) from
## anywhere. Cycles through a small pool of AudioStreamPlayers so
## overlapping sounds (e.g. footsteps + a tool swing) don't cut each
## other off.

@onready var players: Array[AudioStreamPlayer] = [
	$Player0, $Player1, $Player2, $Player3,
]

var _next_index: int = 0


func play(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	var player: AudioStreamPlayer = players[_next_index]
	_next_index = (_next_index + 1) % players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.play()
