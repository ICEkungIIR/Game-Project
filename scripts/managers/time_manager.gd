extends Node

## Autoload singleton: TimeManager
## Add as Autoload named "TimeM" in Project Settings.
## Drives the day counter that Farm/Monster systems listen to, plus an
## in-day clock (hour/minute) for the time_HUD display and future
## day-night cycle work.

signal day_started(day_number: int)
signal time_changed(hour: int, minute: int)

var current_day: int = 1
var hour: int = 6
var minute: float = 0.0

## Set true (e.g. by QuotaManager on game over/win) to freeze the clock.
var time_paused: bool = false

## In-game minutes that pass per real second. 2.0 = a full 24h in-game
## day takes 12 real minutes (1440 in-game minutes / 2.0 per second = 720
## real seconds).
@export var minutes_per_real_second: float = 2.0


func _process(delta: float) -> void:
	if time_paused:
		return
	minute += minutes_per_real_second * delta
	if minute >= 60.0:
		minute = fmod(minute, 60.0)
		hour += 1
		if hour >= 24:
			hour = 0
			next_day()
	time_changed.emit(hour, int(minute))


func next_day() -> void:
	current_day += 1
	day_started.emit(current_day)
	# Farm.gd and Monster.gd should connect to this signal to:
	# - grow crops one stage
	# - regenerate monster products
	# - reset tavern customer state
