extends Control

## Attach to day_HUD.tscn root (Control).
## Syncs the Label with the TimeM autoload (time_manager.gd).

@onready var label: Label = $Label


func _ready() -> void:
	TimeM.day_started.connect(_on_day_started)
	_on_day_started(TimeM.current_day)


func _on_day_started(day_number: int) -> void:
	label.text = "Day %d" % day_number
